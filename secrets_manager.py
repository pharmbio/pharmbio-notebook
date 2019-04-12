### THIS SCRIPT WILL PRINT ALL SECRETS IN THE CREDENTIALS FOLDER FOR YOU TO USE FOR OTHER STUFF

from os import listdir, path

secrets = [path.join("/credentials", item) for item in listdir("/credentials")]

for secret in secrets:
    files = [path.join(secret, key) for key in list(filter(lambda s: not s[0] == ".", listdir(secret)))]
    for key in files:
        keyname = key.split('/')[len(key.split('/'))-1]
        print(key)
        value = None
        with open(key, 'r') as keyfile:
            value = keyfile.read()
        print("Key: {}, value: {}\n".format(keyname, value))



