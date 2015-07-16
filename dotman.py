#! /usr/bin/env python2

import os
import argparse
import logging
import subprocess
import shutil
import socket
import hashlib
import fnmatch

# Initialize Logging
logging.basicConfig(format='%(message)s', level=logging.INFO)
log = logging.getLogger(__name__)


def main():
    """Dotfile manager.

       All dotfiles are kept in a specific directory within a git repository.
       The dotman script then creates symlink in the home directory pointing to the files in the dotman
       repository. It also supports host specific dotfiles within the subfolder hosts/HOSTNAME. Dotfiles
       in this directory prevail dotfiles in the specific directory.
    """
    parser = argparse.ArgumentParser(description='Manages dotfiles.')
    subparsers = parser.add_subparsers()

    global_parser = argparse.ArgumentParser(add_help=False)
    global_parser.add_argument('--dotfiles_dir',
                             default=os.path.join(os.getenv('HOME'), '.dotfiles'),
                             help='Directory in which dotfiles are located.')
    global_parser.add_argument("--log-level", default="info",
                               help="Log level.")

    # Status
    parser_status = subparsers.add_parser('status', help='Show status of all dotfiles',
                                          parents=[global_parser])
    parser_status.set_defaults(func=print_status)

    # Install/symlink dotfiles
    parser_install = subparsers.add_parser('install', help='Install or update symlinks.',
                                           parents=[global_parser])
    parser_install.set_defaults(func=install_symlinks)
    parser_install.add_argument('-f', '--force', action='store_true',
                                help='Overwrite existing config files')

    # Add additional files
    parser_add = subparsers.add_parser('add', parents=[global_parser])
    parser_add.set_defaults(func=add_files)
    parser_add.add_argument('files', nargs='*', help='Add files to dotfiles repo.')

    log.debug('Parsing args')
    args = vars(parser.parse_args())

    # Setup logger
    log_level = getattr(logging, args['log_level'].upper(), None)
    if not isinstance(log_level, int):
        raise ValueError('Invalid log level: %s' % log_level)
    log.setLevel(log_level)

    # Call specified subcommand function
    args['func'](**args)


def install_symlinks(**kwargs):
    """ Install symlinks for all dotfiles in repo.

        At first symlink all files in dotfiles root repo. If there are
        host specific dotfiles in dotfiles_dir/hosts/hostname/ symlink them
        too.
    """
    log.info('Installing symlinks')
    dotfiles_dir = kwargs.pop('dotfiles_dir')
    force_install = kwargs.pop('force')

    # Sync global dotfiles
    log.debug("Symlinking all files in {0}.".format(dotfiles_dir))
    dotfiles = get_all_dotfiles(dotfiles_dir)
    for dotfile in dotfiles:
        symlink_file(dotfile, force_install=force_install, dotfiles_dir=dotfiles_dir)

    # If host specific dotfiles available sync them too.
    host_dirs = [x[0] for x in os.walk(os.path.join(dotfiles_dir, 'hosts'))]
    for host_dir in host_dirs:
        if fnmatch.fnmatch(os.path.basename(host_dir), get_hostname()):
            dotfiles = get_all_dotfiles(dotfiles_dir)
            for dotfile in dotfiles:
                symlink_file(dotfile, force_install=force_install, dotfiles_dir=dotfiles_dir)


def symlink_file(dotfile, force_install=False, dotfiles_dir=None):
    """ Create symlink in homefolder to dotfile if all checks pass."""

    linkname = get_homefolder_path(dotfile, dotfiles_dir)
    # Check if link is a valid link to dotfile
    if has_valid_link(dotfile, dotfiles_dir):
        log.debug('Already a valid symlink: {0}.'.format(dotfile))
        return
    # Check and remove broken symlinks
    if os.path.islink(linkname) and not os.path.exists(os.readlink(linkname)):
        log.debug('{0} is an invalid link. Will be removed.'.format(linkname))
        os.unlink(linkname)
    # If existing link points to another file remove link.
    if os.path.islink(linkname) and not os.readlink(linkname) == dotfile:
        log.debug('{0} is pointing to a different file. Removing the symlink.'.format(linkname))
        os.unlink(linkname)

    # Check if real path exists.
    if os.path.exists(linkname) and (not os.path.islink(linkname)):
        # If file hashs are equal, if yes just replace
        if get_hash(linkname) == get_hash(dotfile):
            log.debug('Home folder file and dotfile are identical')
            log.debug('Replacing home folder file with symlink to dotfile')
            os.remove(linkname)
        elif force_install:
            log.warning('Overwriting file {0}.'.format(linkname))
            os.remove(linkname)
        else:
            log.info('File {0} already exists, but is not identical to dotfile'.format(linkname))
            log.info('If you want to override that file you must specify the \'-f\' option.')
            log.debug('Skipping file {0}.'.format(linkname))
            return
    # TODO Check if containing folder is a symlink to .dotfiles since this
    # would create a link loop.
    log.debug('All checks are succesful:'.format(linkname, dotfile))
    directory = os.path.dirname(linkname)
    if not os.path.exists(directory):
        log.debug('Directory structure did not yet exist. Directories are created.')
        os.makedirs(directory)
    if not os.path.exists(linkname):
        log.debug('Symlinking {0} to {1}'.format(linkname, dotfile))
        os.symlink(dotfile, linkname)
    else:
        log.warning('Cannot create symlink. File {0} exists.'.format(linkname))


def add_files(**kwargs):
    """Add files to dotfile repository."""
    files = kwargs['files']
    for filename in files:
        path = os.path.abspath(filename)
        relpath = os.path.relpath(path, os.getenv('HOME'))
        # Dotfile path without leading dot
        dotfilepath = os.path.join(kwargs['dotfiles_dir'], relpath.lstrip('.'))

        # Path must be in home
        if not os.getenv('HOME') in path:
            log.warning('Only files in home folder can be handled.')
            continue

        # relative path must start with dot
        if not relpath.startswith('.'):
            log.warning('File is not a dotfile.')
            continue

        if os.path.exists(os.path.join(kwargs['dotfiles_dir'], relpath)):
            log.warning('File already in dotfiles directory')
            continue
        log.info('Moving file {0} to {1}.'.format(path, dotfilepath))
        # Create directory structure if neccesary
        directory = os.path.dirname(dotfilepath)
        if not os.path.exists(directory):
            os.makedirs(directory)
        shutil.move(path, dotfilepath)


def print_status(**kwargs):
    dotfiles_dir = kwargs['dotfiles_dir']
    print 'Status of all dotfiles:'
    dotfiles = get_all_dotfiles(dotfiles_dir, sorted=True)

    print "{0:<35}{1:>8}".format('Dotfile', 'Symlink status')
    for dotfile in dotfiles:
        symlink_status = 'good' if has_valid_link(dotfile, dotfiles_dir) else 'bad'
        print "{0:<35}{1:>8}".format(get_rel_path(dotfile, dotfiles_dir),
                                                symlink_status)

def get_all_dotfiles(dotfiles_dir, sorted=False):
    """Returns list of all dotfiles.

       Walks over all files in the dotfiles directory and returns list of all files.
       The .git folder and the filename of the script (dotman.py) are ommitted.
    """
    exclude_dirs = ['.git', 'hosts', '.idea']
    exclude_files = [os.path.basename(__file__), '.*', 'README.md']
    dotfiles = []
    for root, dirs, files in os.walk(dotfiles_dir, topdown=True):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        files = [f for f in files if not any([fnmatch.fnmatch(f, pat) for pat in exclude_files])]
        dotfiles += [os.path.join(root,f) for f in files]
    if sorted:
        dotfiles.sort()
    return dotfiles


def get_homefolder_path(dotfile, dotfiles_dir):
    """Return corresponding path of dotfile in homefolder."""
    relpath = get_rel_path(dotfile, dotfiles_dir)
    linkname = os.path.join(os.getenv('HOME'), '.{0}'.format(relpath))
    return linkname


def get_rel_path(filepath, dotfiles_dir):
    """Returns relative path of filepath compared to dotfiles_dir."""
    relpath = os.path.relpath(filepath, dotfiles_dir)
    return relpath


def has_valid_link(dotfile, dotfiles_dir):
    """Checks that dotfile has a valid link in the homefolder.
    """
    homefolder_path = get_homefolder_path(dotfile, dotfiles_dir)
    if os.path.islink(homefolder_path) and os.readlink(homefolder_path) == dotfile:
        return True

    return False


def is_tracked(filename, gitrepo):
    """ Returns True if file is tracked within gitrepo. filename needs to be
        relative to gitrepo.
    """
    gitrepodir = os.path.join(gitrepo, '.git')
    cmd = 'git --git-dir {0} ls-files --error-unmatch {1}'.format(gitrepodir, filename)
    print cmd
    rc = subprocess.call(cmd.split())
    return False if rc else True


def get_hash(filename, blocksize=65536):
    """Return sha256 hash of file content."""
    with open(filename, 'rb') as afile:
        hasher = hashlib.sha256()
        buf = afile.read(blocksize)
        while len(buf) > 0:
            hasher.update(buf)
            buf = afile.read(blocksize)
        return hasher.hexdigest()

def get_hostname(short=False):
    """ Returns hostname of machine. If short is True returns hostname up
        to first dot.
    """
    hostname = socket.gethostname()
    if short:
        hostname = hostname.split('.')[0]
    return hostname

if __name__ == '__main__':
    main()
