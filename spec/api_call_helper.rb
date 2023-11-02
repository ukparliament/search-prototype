def when_online
  if test_remote_connectivity
    yield
  else
    puts "Skipping test offline."
  end
end
