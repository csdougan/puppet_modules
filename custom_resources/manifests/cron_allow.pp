define custom_resources::cron_allow () {
  augeas { "ensure user ${title} is in cron.allow" :
    context => "/files/etc/cron.allow",
    changes => "set 1[last()+1] ${title}",
    onlyif  => "match *[.='${title}'] size == 0",
  }
}

