#!/bin/bash

function thought() {
  local msg="$*"
  [[ -z "$msg" ]] && msg="Simple, Elegant, Flexible, Nothing..."

  local content="$(date "+%Y-%m-%d %H:%M:%S") $msg"
  local thoughts_filepath="$HOME/OuterGitRepo/blog-gallary/source/thoughts/index.md"

  cd $HOME/OuterGitRepo/blog-gallary

  if [ "$1" = "--edit" -o "$1" = "-e" ]; then
    vi source/thoughts/index.md
    return 0
  fi

  if [ "$1" = "--interactive" -o "$1" = "-i" ]; then
    echo -n "Please type in your thoughts(ctrl+c to interrupt): "
    read msg
    if [ $? != 0 ]; then return $?; fi

    local content="$(date "+%Y-%m-%d %H:%M:%S") $msg"
  fi

  echo $content
  # macos use gsed, not builtin sed
  gsed -i "6i - ${content}" $thoughts_filepath
  gsed -i "6G" $thoughts_filepath

  git add . &&
  git commit -m "Add thought via cli." --quiet &&
  git push --quiet &&
  NODE_OPTIONS="--trace-warnings" hexo clean  >/dev/null &&
  NODE_OPTIONS="--trace-warnings" hexo deploy >/dev/null &&
  ssh webuser@xiaoli "cd /srv/www/blog-gallary &&
                      git fetch         &&
                      git checkout main &&
                      git reset --hard HEAD@{u}"

  cd -
  echo
  echo "open $BLOG_DOMAIN/thoughts"
}
