#!/bin/sh

echo Content-type: text/html
echo ""

/bin/cat << EOM
<HTML>
<HEAD><TITLE>FIRESTOR</TITLE>
</HEAD>
<BODY>
<P>
<SMALL>
<PRE>
EOM

ls -la /firestor


/bin/cat << EOM
</PRE>
</SMALL>
</P>
<br><br>
<P>
<SMALL>
<PRE>
EOM

df /firestor/ -h


/bin/cat << EOM
</PRE>
</SMALL>
</P>
</BODY>
</HTML>
EOM