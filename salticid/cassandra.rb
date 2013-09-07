role :cassandra do
  task :setup do
    sudo do
      echo "deb http://www.apache.org/dist/cassandra/debian 12x main
deb-src http://www.apache.org/dist/cassandra/debian 12x main",
        to: '/etc/apt/sources.list.d/cassandra.list'
      exec! 'gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D'
      exec! 'gpg --export --armor F758CE318D77295D | apt-key add -'
      exec! 'gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00'
      exec! 'gpg --export --armor 2B5C1B00 | apt-key add -'
      exec! 'apt-get update', echo: true
      exec! 'apt-get install -y cassandra', echo: true
    end
    cassandra.deploy
  end

  task :tail do
    sudo do
      tail '-F', '/var/log/cassandra/output.log', echo: true
    end
  end

  task :start do
    sudo do
      service :cassandra, :start
    end
  end

  task :stop do
    sudo do
      service :cassandra, :stop
    end
  end

  task :restart do
    sudo do
      service :cassandra, :restart
    end
  end

  task :nuke do
    sudo do
      cassandra.stop rescue nil
      exec! 'rm -rf /var/lib/cassandra/commitlog/*'
      exec! 'rm -rf /var/lib/cassandra/data/*'
      exec! 'rm -rf /var/lib/cassandra/saved_caches/*'
      exec! 'rm -rf /var/log/cassandra/*'
    end
  end

  task :deploy do
    sudo do
      ip = dig '+short', name
      echo File.read(__DIR__/:cassandra/'cassandra.yaml').gsub('%%IP%%', ip),
        to: '/etc/cassandra/cassandra.yaml'
      sudo_upload __DIR__/:cassandra/'cassandra-env.sh', '/etc/cassandra/cassandra-env.sh'
    end
    cassandra.restart
  end
end
