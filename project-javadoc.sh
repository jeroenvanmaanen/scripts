#!/bin/bash

if [ ! -e './pom.xml' ]
then
    echo "Missing POM: $(pwd)" >&2
    exit 1
fi

CWD="$(pwd)"
(
    PARENT="$(cd .. ; pwd)"
    while [ "//${PARENT}" != "//${CWD}" -a -e "../pom.xml" ]
    do
        cd ..
        CWD="${PARENT}"
        PARENT="$(cd .. ; pwd)"
    done
    pwd >&2
    mvn javadoc:javadoc
    PROJECT_DOC='target/site/apidocs'
    mkdir -p "${PROJECT_DOC}"
    (
        echo '<html>
<head><title>Javadoc</title></head>
<body>
<h2>Javadoc</h2>
<ul>'
        sfind.sh * -name apidocs -print \
            | sed -E -n -e 's:^((.*)/target/site/apidocs):<li><a href="../../../\1/index.html">\2</a></li>:p'
        echo '</ul>
</body>
</html>'
    ) > "${PROJECT_DOC}/index.html"
)
