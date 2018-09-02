sudo apt-get update
sudo apt-get upgrade

sudo apt-get install python-software-properties software-properties-common

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.1/elasticsearch-2.3.1.deb
sudo dpkg -i elasticsearch-2.3.1.deb
sudo update-rc.d elasticsearch defaults 95 10
sudo /etc/init.d/elasticsearch start


-------------------------------------------------------------------


sudo apt-get update
sudo apt-get install default-jre
sudo update-alternatives --config java
sudo nano /etc/environment
source /etc/environment
echo $JAVA_HOME

cd ~
mkdir sencha
wget http://cdn.sencha.com/cmd/6.5.3.6/no-jre/SenchaCmd-6.5.3.6-linux-amd64.sh.zip -o SenchaCmd-6.5.3.6-linux-amd64.sh.zip
unzip SenchaCmd-6.5.3.6-linux-amd64.sh.zip -d sencha

sencha/SenchaCmd-6.5.3.6-linux-amd64.sh -q

# /home/user/bin/Sencha/Cmd/6.5.3.6
sudo nano /etc/environment
source /etc/environment

cd ~/site/extjs
screen -S thesis-view -d -m sencha app watch