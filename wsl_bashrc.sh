export WSL=true

sudo run-parts /etc/update-motd.d

for file in ~/.bashrc.d/*.bashrc;
do
source "$file"
done
