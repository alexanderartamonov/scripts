#!/usr/bin/env python
# Python Script to swap AWS Profile configs

# Assumes that credentials file is at ~/.aws/credentials

import argparse

import os
import subprocess
import json


# Config = ConfigParser.ConfigParser()
# Config.read(os.path.expanduser('~/.aliyun/config.json'))




def get_profile_to_swap_to():
    alicloud_config = open('/Users/oleksandrartamonov/.aliyun/config.json')
    """Parse the profile requested from user input"""
    data = json.load(alicloud_config)
    for i in data['profiles']:
        print(i)

# def get_profile_to_swap_to():
#     """Parse the profile requested from user input"""
#     parser = argparse.ArgumentParser()
#     parser.add_argument("profile", help="profile to set as default")
#     args = parser.parse_args()
#     profile_to_swap_to = args.profile
#     sections = Config.sections()
#     profiles = " ".join(str(item) for item in sections)
#     print(('\033[38;5;220mAvailable AWS Profiles: ')+'\033[38;5;202m'+profiles+'\n'+'\033[0;0m')
#     if profile_to_swap_to in sections:
#         return profile_to_swap_to
#     else:
#         section_list = ''
#         for i in sections:
#             section_list += (i + '\n')
#         raise ValueError(
#             "The profile '{0}' is not in your credentials file. \n\n" \
#             "Available profiles are:\n{1}".format(
#                 profile_to_swap_to, 
#                 section_list
#             )
#         )

# def swap_profile(profile_to_swap_to):

#     key = Config.get(profile_to_swap_to, 'aws_access_key_id')
#     secret = Config.get(profile_to_swap_to, 'aws_secret_access_key')
#     Config.set('default', 'aws_access_key_id', key)
#     Config.set('default', 'aws_secret_access_key', secret)
#     with open(os.path.expanduser('~/.aws/credentials'), 'wb') as configfile:
#         Config.write(configfile)

def main():
    get_profile_to_swap_to()
    #profile = get_profile_to_swap_to()
    # swap_profile(profile)
    #print('\033[38;5;220mSwapped to profile: {0}'.format('\033[38;5;202m'+profile+'\033[0;0m\n'))
    push=subprocess.call(['aliyun', 'sts', 'GetCallerIdentity'])
if __name__ == "__main__":
    main()
