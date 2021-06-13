for file in ~/.bashrc.d/*.bashrc;
do
source "$file"
done

x11vnc -forever -loop -noxdamage -repeat -rfbport 5900 -shared --display :0 &
