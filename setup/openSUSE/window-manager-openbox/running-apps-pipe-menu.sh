#!/bin/bash
echo '<openbox_pipe_menu>'
wmctrl -l | while read -r window; do
  id=$(echo $window | cut -d' ' -f1)
  title=$(echo $window | cut -d' ' -f4-)
  echo "<item label=\"$title\">"
  echo "  <action name=\"Execute\"><command>wmctrl -i -R $id</command></action>"
  echo "</item>"
done
echo '</openbox_pipe_menu>'
