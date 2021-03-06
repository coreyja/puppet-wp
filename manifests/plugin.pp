define wp::plugin (
	$slug = $title,
	$location,
	$ensure = enabled,
	$networkwide = false
) {
	include wp::cli

	case $ensure {
		enabled: {
			$command = "activate $slug"

			exec { "wp install plugin $title":
				cwd     => $location,
				command => "/usr/local/bin/wp plugin install $slug",
				unless  => "/usr/local/bin/wp plugin is-installed $slug",
				before  => Wp::Command["$location plugin $slug $ensure"],
				require => Class["wp::cli"],
				onlyif  => "/usr/local/bin/wp core is-installed"
			}
		}
		disabled: {
			$command = "deactivate $slug"
		}
		default: {
			fail("Invalid ensure for wp::plugin")
		}
	}

	if $networkwide {
		$args = "plugin $command --network"
	}
	else {
		$args = "plugin $command"
	}
	wp::command { "$location plugin $slug $ensure":
		location => $location,
		command => $args
	}
}
