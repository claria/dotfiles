#! /usr/bin/env python2

import os
import sys
import argparse
import logging
import subprocess
import shutil
import fnmatch

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

    # Install/symlink dotfiles
    parser_install = subparsers.add_parser('install', help='Install or update symlinks.',
                                           parents=[glob_parser])
    parser_install.set_defaults(func=install_symlinks)
    parser_install.add_argument('--force_install', '-f', action='store_true',
                                help='Overwrite existing config files')

    # Uninstall
    parser_uninstall = subparsers.add_parser('uninstall', parents=[glob_parser])
    parser_uninstall.set_defaults(func=uninstall_symlinks)

    # Add additonal files
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
    dotfiles = []
    for root, dirnames, filenames in os.walk(dotfiles_dir):
        if '.git' in root:
            continue
        for filename in filenames:
            # Remove dotman from list
            if os.path.realpath(__file__) == filename:
                continue
            path = os.path.join(root, filename)
            dotfiles.append(path)

    # Symlink each file
    for filepath in dotfiles:
        relpath = os.path.relpath(filepath, dotfiles_dir)
        linkname = os.path.join(os.getenv('HOME'), '.{0}'.format(relpath))
        # Check and remove broken symlinks
        print linkname
        if os.path.islink(linkname) and not os.path.exists(os.readlink(linkname)):
            os.remove(linkname)
        # Check if real path exists.
        if os.path.exists(linkname):
            log.info('File {0} exists.'.format(linkname))
            if kwargs['force_install']:
                log.warning('Removing file {0}.'.format(linkname))
                os.remove(linkname)
            else:
                log.info('Skipping file {0}.'.format(linkname))
                continue

        log.debug('Symlinking {0} to {1}'.format(linkname, filepath))
        directory = os.path.dirname(linkname)
        if not os.path.exists(directory):
            os.makedirs(directory)
        os.symlink(filepath, linkname)


def uninstall_symlinks():
    log.info('Uninstalling symlinks')
    pass


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


def remove_files(**kwargs):
    # remove symlink in HOME
    # mv file to HOME
    pass


def istracked(gitrepo, filename):
    """ Returns True if file is tracked within gitrepo.
    """
    gitrepodir = os.path.join(gitrepo, '.git')
    cmd = 'git --git-dir {0} ls-files --error-unmatch {0}'.format(gitrepodir, filename)
    print cmd
    rc = subprocess.call(cmd.split())
    return False if rc else True

if __name__ == '__main__':
    main()
