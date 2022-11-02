## download all images from a tor *.onion url using wget
## apt install -y tor
## any wget or curl command must start with 'torsocks' to route over the tor network

torsocks wget -nd -r -P /path/to/folder/ -A jpeg,jpg,bmp,gif,png tor_website_Address

