#! /usr/bin/env python2

import os
import argparse
import logging
import subprocess
import shutil
import socket
import hashlib

# Initialize Logging
log = logging.getLogger(__name__)


def main():
    """Tool for managing dotfiles."""
    parser = argparse.ArgumentParser(description='Handle dotfiles.')
    parser.add_argument("--log-level", default="info",
                        help="Log level.")
    subparsers = parser.add_subparsers()

    glob_parser = argparse.ArgumentParser(add_help=False)
    glob_parser.add_argument('--dotfiles_dir',
                             default=os.path.join(os.getenv('HOME'), '.dotfiles'),
                             help='Directory in which dotfiles are located.')

    # Status
    parser_status = subparsers.add_parser('status', help='Show status of all dotfiles',
                                          parents=[glob_parser])
    parser_status.set_defaults(func=print_status)

    # Install/symlink dotfiles
    parser_install = subparsers.add_parser('install', help='Install or update symlinks.',
                                           parents=[glob_parser])
    parser_install.set_defaults(func=install_symlinks)
    parser_install.add_argument('--force_install', '-f', action='store_true',
                                help='Overwrite existing config files')

    # Uninstall
    parser_uninstall = subparsers.add_parser('uninstall', parents=[glob_parser])
    parser_uninstall.set_defaults(func=uninstall_symlinks)

    # Add additional files
    parser_add = subparsers.add_parser('add', parents=[glob_parser])
    parser_add.set_defaults(func=add_files)
    parser_add.add_argument('files', nargs='*', help='Add files to dotfiles repo.')

    # Remove dotfiles
    parser_remove = subparsers.add_parser('remove', parents=[glob_parser])
    parser_remove.set_defaults(func=remove_files)
    parser_remove.add_argument('files', nargs='*', help='Remove files from dotfiles repo.')

    log.debug('Parsing Args')
    args = vars(parser.parse_args())
    # Setup logger
    log_level = getattr(logging, args['log_level'].upper(), None)
    if not isinstance(log_level, int):
        raise ValueError('Invalid log level: %s' % log_level)
    logging.basicConfig(format='%(message)s',
                        level=log_level)
    args['func'](**args)


def install_symlinks(**kwargs):
    """ Symlinks all files to home directory
    """
    log.info('Installing symlinks')
    dotfiles_dir = kwargs.pop('dotfiles_dir')
    force_install = kwargs.pop('force_install')
    # Sync global dotfiles
    symlink_files(dotfiles_dir, force_install=force_install)
    # If host specific dotfiles available sync them too.
    host_dotfiles_dir = os.path.join(dotfiles_dir, 'hosts', get_hostname())
    if os.path.isdir(host_dotfiles_dir):
        symlink_files(host_dotfiles_dir, force_install=force_install)


def symlink_files(dotfiles_dir, force_install=False):
    # Only files, no directories, are symlinked. But the directory structure is preserved.
    log.debug("Symlinking all files in {0}.".format(dotfiles_dir))
    dotfiles = get_all_dotfiles(dotfiles_dir)
    print dotfiles
    # Symlink each file
    for dotfile in dotfiles:
        linkname = get_homefolder_path(dotfile, dotfiles_dir)
        # Check if link is a valid link to dotfile
        if has_valid_link(dotfile, dotfiles_dir):
            log.debug('Already a valid symlink: {0}.'.format(dotfile))
            continue
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
            if hash_file(linkname) == hash_file(dotfile):
                log.debug('Home folder file and dotfile are identical')
                log.debug('Replacing home folder file with symlink to dotfile')
                print "linkname", linkname
                os.remove(linkname)
            elif force_install:
                log.warning('Overwriting file {0}.'.format(linkname))
                os.remove(linkname)
            else:
                log.info('File {0} already exists, but is not identical to dotfile'.format(linkname))
                log.info('If you want to override that file you must specify the \'-f\' option.')
                log.debug('Skipping file {0}.'.format(linkname))
                continue
        # TODO Check if folder, if existing, is a symlink already to .dotfiles.
        # This would create a loop.
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


def uninstall_symlinks():
    log.info('Uninstalling symlinks')
    log.error('Not implemented.')
    raise NotImplementedError


def add_files(**kwargs):
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
    dotfiles = get_all_dotfiles(dotfiles_dir)

    for dotfile in dotfiles:
        print "{}:".format(get_rel_path(dotfile, dotfiles_dir))
        print "  Dotpath:   {}".format(dotfile)
        print "  Homepath:  {}".format(get_homefolder_path(dotfile, dotfiles_dir))
        print "  Symlinked: {}".format(has_valid_link(dotfile, dotfiles_dir))


def remove_files(**kwargs):
    """ Removes all symlinks in home directory pointing to a dotfile and replaces them
        with the actual files from the dotfiles repo. After that it is safe to delete the
        dotfiles repository.
    """
    # TODO:
    # Remove symlink in HOME
    # Move all dotfiles to HOME
    _ = kwargs
    raise NotImplementedError


####################
# Helper functions #
####################

def get_all_dotfiles(dotfiles_dir):
    """Returns list of all dotfiles.

       Walks over all files in the dotfiles directory and returns list of all filenames.
       The .git folder and the filename of the script (dotman.py) are ommitted.
    """
    dotfiles = []
    exclude = {'.git', 'hosts', '.idea'}
    for root, dirs, filenames in os.walk(dotfiles_dir, topdown=True):
        dirs[:] = [d for d in dirs if d not in exclude]
        for filename in filenames:
            # Remove dotman from list
            if os.path.basename(__file__) == filename:
                continue
            if filename.startswith('.'):
                continue
            path = os.path.join(root, filename)
            dotfiles.append(path)
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
    """Returns true if homefolder_path is a link and if this link points to the dotfile."""
    homefolder_path = get_homefolder_path(dotfile, dotfiles_dir)
    if os.path.islink(homefolder_path) and os.readlink(homefolder_path) == dotfile:
        return True

    return False


def is_tracked(gitrepo, filename):
    """ Returns True if file is tracked within gitrepo."""
    gitrepodir = os.path.join(gitrepo, '.git')
    cmd = 'git --git-dir {0} ls-files --error-unmatch {1}'.format(gitrepodir, filename)
    print cmd
    rc = subprocess.call(cmd.split())
    return False if rc else True


def hash_file(fname, blocksize=65536):
    """Return sha256 hash of file."""
    with open(fname, 'rb') as afile:
        hasher = hashlib.sha256()
        buf = afile.read(blocksize)
        while len(buf) > 0:
            hasher.update(buf)
            buf = afile.read(blocksize)
        return hasher.hexdigest()

def get_hostname():
    return socket.gethostname()

if __name__ == '__main__':
    main()
