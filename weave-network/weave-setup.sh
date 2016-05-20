#on each host
sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave

#on host 1
weave launch

#on host 2
weave launch 159.122.251.69


#scope - for container network visualisation
sudo wget -O /usr/local/bin/scope https://github.com/weaveworks/scope/releases/download/latest_release/scope
sudo chmod a+x /usr/local/bin/scope
scope launch

#then visit: http://159.122.251.69:4040/