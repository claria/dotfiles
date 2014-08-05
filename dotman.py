#! /usr/bin/env python2

import os
import sys
import argparse
import logging
import subprocess
import shutil
import fnmatch
import socket
import hashlib

# Initialize Logging
logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
log = logging.getLogger(__name__)


def main():
    """
    Simple tool for managing dotfiles.
    """
    parser = argparse.ArgumentParser(description='Handle dotfiles.')
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
    clargs = vars(parser.parse_args())
    clargs['func'](**clargs)


def install_symlinks(**kwargs):
    """ Symlinks all files to home directory
    """
    log.info('Installing symlinks')
    dotfiles_dir = kwargs['dotfiles_dir']

    # Only real files are symlinked no folders
    # but the directory structure is preserved
    dotfiles = get_all_dotfiles(dotfiles_dir)


    # Symlink each file
    for filepath in dotfiles:
        linkname = get_homefolder_path(filepath, dotfiles_dir)
        log.debug('Try to link {0} against target {1}'.format(linkname, filepath))

        # Check and remove broken symlinks
        if os.path.islink(linkname) and not os.path.exists(os.readlink(linkname)):
            os.remove(linkname)

        # Check if link is a valid link to dotfile
        if is_valid_link(filepath, dotfiles_dir):
            log.debug('Nothing to do for dotfile {0}'.format(filepath))
            continue
 
        # Check if real path exists.
        if os.path.exists(linkname) and (not os.path.islink(linkname)):
            log.debug('File {0} already exists.'.format(linkname))
            if kwargs['force_install']:
                log.warning('Overwriting file {0}.'.format(linkname))
                os.remove(linkname)
            #Check if files are equal, if yes just replace
            elif (hashfile(linkname) == hashfile(filepath)):
                log.debug('Home folder file and dotfile are identical')
                log.debug('Replacing home folder file with symlink to dotfile')
                os.remove(linkname)
            else:
                log.debug('Skipping file {0}.'.format(linkname))
                continue

        
        log.debug('Symlinking {0} to {1}'.format(linkname, filepath))
        directory = os.path.dirname(linkname)
        if not os.path.exists(directory):
            os.makedirs(directory)
        print filepath
        print linkname
        # os.symlink(filepath, linkname)


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
        print "  Symlinked: {}".format(is_valid_link(dotfile, dotfiles_dir))




def remove_files(**kwargs):
    # remove symlink in HOME
    # mv file to HOME
    pass

####################
# Helper functions #
####################

def get_all_dotfiles(dotfiles_dir):
    dotfiles = []
    for root, dirnames, filenames in os.walk(dotfiles_dir):
        if '.git' in root:
            continue
        if 'host_' in os.path.basename(root):
            if os.path.basename(root) == 'host_' + socket.gethostname():
                raise NotImplementedError
                continue
            else:
                continue
        for filename in filenames:
            # Remove dotman from list
            if os.path.basename(__file__) == filename:
                continue
            if filename.startswith('.'):
                continue
            path = os.path.join(root, filename)
            dotfiles.append(path)

    return dotfiles

def get_homefolder_path(filepath, dotfiles_dir):
    relpath = get_rel_path(filepath, dotfiles_dir)
    linkname = os.path.join(os.getenv('HOME'), '.{0}'.format(relpath))
    return linkname


def get_rel_path(filepath, dotfiles_dir):
    relpath = os.path.relpath(filepath, dotfiles_dir)
    return relpath

def is_valid_link(dotfile, dotfiles_dir):

    homefolder_path = get_homefolder_path(dotfile, dotfiles_dir)
    if os.path.islink( homefolder_path):
        if (os.path.realpath(homefolder_path) == dotfile):
            return True
        else: 
            return False
    else:
        return False


def istracked(gitrepo, filename):
    """ Returns True if file is tracked within gitrepo.
    """
    gitrepodir = os.path.join(gitrepo, '.git')
    cmd = 'git --git-dir {0} ls-files --error-unmatch {1}'.format(gitrepodir, filename)
    print cmd
    rc = subprocess.call(cmd.split())
    return False if rc else True


def hashfile(fname, blocksize=65536):
    """ Return sha256 hash of file"""
    afile = open(fname, 'rb')
    hasher = hashlib.sha256()
    buf = afile.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = afile.read(blocksize)
    return hasher.hexdigest()


if __name__ == '__main__':
    main()
