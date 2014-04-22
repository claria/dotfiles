#! /usr/bin/env python2

import os
import sys
import argparse
import glob
import logging
import subprocess

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
log = logging.getLogger(__name__)

def main():

    parser = argparse.ArgumentParser(description='Handle dotfiles.')
    parser.add_argument('--dotfiles_dir',
                        default=os.path.join(os.getenv('HOME'), '.dotfiles'),
                        help='Directory in which dotfiles are located.')

    subparsers = parser.add_subparsers()

    parser_install = subparsers.add_parser('install')
    parser_install.set_defaults(func=install_symlinks)
    parser_install.add_argument('--force_install', '-f', action='store_true',
                                help='Overwrite existing config files')


    parser_uninstall = subparsers.add_parser('uninstall')
    parser_uninstall.set_defaults(func=uninstall_symlinks)

    parser_update = subparsers.add_parser('update')
    parser_update.set_defaults(func=update_symlinks)

    log.debug('Parsing Args')
    clargs = vars(parser.parse_args())

    clargs['func'](**clargs)



def install_symlinks(**kwargs):
    """ Symlinks all files to home directory
    """
    log.info('Installing symlinks')
    dotfiles_dir = kwargs['dotfiles_dir']
    dotfiles = glob.glob(os.path.join(dotfiles_dir, '*'))
    # Remove dotman from list
    if os.path.realpath(__file__) in dotfiles:
        dotfiles.remove(os.path.realpath(__file__))

    # Symlink each file
    for filepath in dotfiles:
        linkname = os.path.join(os.getenv('HOME'), '.' + os.path.basename(filepath))
        # Check and remove broken symlinks
        if os.path.islink(linkname) and not os.path.exists(os.readlink(linkname)):
            os.remove(linkname)
        # Check if real path exists.
        if os.path.exists(linkname):
            log.info('File {} exists.'.format(linkname))
            if kwargs['force_install']:
                log.warning('Removing file {}.'.format(linkname))
                os.remove(linkname)
            else:
                log.info('Skipping file {}.'.format(linkname))
                continue

        log.debug('Symlinking {} to {}'.format(linkname, filepath))
        os.symlink(filepath, linkname)


def uninstall_symlinks():
    log.info('Uninstalling symlinks')
    pass

def update_symlinks():
    pass


def istracked(gitrepo, filename):
    gitrepodir = os.path.join(gitrepo, '.git')
    cmd = 'git --git-dir {} ls-files --error-unmatch {}'.format(gitrepodir, filename)
    rc = subprocess.call(cmd.split())
    return False if rc else True

if __name__ == '__main__':
    main()
