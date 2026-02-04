# Garage Dev

A simple docker image to use garage in a dev environment.

AND ONLY IN DEV. DO NOT USE IN PROD.

## Whats that?

That's a simple startup script for Garage that takes a GARAGE_BUCKET env var and does the following:
- Setup a simple layout if none is set
- Apply it
- Create the bucket if it does not exists
- Create a key
- Gives it the permissions on it
- Write the info in `/opt/garage/credentials.json` so that you can fetch it in your app

So basically, with this image, you can start a garage instance instantly and have it being usable as any "fakes3" container you might want (All of them are unmaintained :/).

This also helps you reset it quickly (basically do not mount the storage space and you can simply restart the container to have everything wiped)

## Usage

```yaml
services:
    garage:
        image: 'ghcr.io/oxodao/garage:v2.2.0'
        restart: 'unless-stopped'
        environment:
            GARAGE_BUCKET: 'mybucket'
        volumes:
            - './00_DATA/garage/credentials:/opt/garage'
            # - './00_DATA/garage/data:/var/lib/garage' # Only if you want to store the data
        ports:
          - '3900:3900' # S3 Api
          - '3901:3901' # Admin / RPC
          - '3902:3902' # Web API
          - '3903:3903' # Admin
          - '3904:3904' # k2v
        healthcheck:
            test: ['CMD', 'garage-healthcheck']
            start_period: '20s'
            interval: '10s'
            timeout: '2s'
            retries: 5
```


## License

```
           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                   Version 2, December 2004

Copyright (C) 2025 Oxodao

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.
```
