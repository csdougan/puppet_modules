define custom_resources::at_allow () {
  augeas { "ensure user ${title} is in at.allow" :
    context => "/files/etc/at.allow",
    changes => "set 1[last()+1] ${title}",
    onlyif  => "match *[.='${title}'] size == 0",
  }
}

