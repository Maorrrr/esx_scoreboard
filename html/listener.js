
var visable = false;

$(function () {
	window.addEventListener('message', function (event) {

		switch (event.data.action) {
			case 'toggle':
				if (visable) {
					$('#wrap').slideUp(200);
				} else {
					$('#wrap').slideDown(900);
				}

				visable = !visable;
				break;

			case 'close':
				$('#wrap').slideUp();
				visable = false;
				break;

			case 'toggleID':

				if (event.data.state) {
					$('td:nth-child(2),th:nth-child(2)').show();
					$('td:nth-child(5),th:nth-child(5)').show();
				} else {
					$('td:nth-child(2),th:nth-child(2)').hide();
					$('td:nth-child(5),th:nth-child(5)').hide();
				}

				break;

			case 'updatePlayerJobs':
				var jobs = event.data.jobs;

				$('#player_count').html(jobs.player_count);

				$('#ems').html(jobs.ems);
				$('#police').html(jobs.police);
				$('#taxi').html(jobs.taxi);
				$('#mechanic').html(jobs.mechanic);
				$('#cardealer').html(jobs.cardealer);
				$('#estate').html(jobs.estate);
				break;

			case 'updatePlayerList':
				$('#playerlist tr:gt(0)').remove();
				$('#playerlist').append(event.data.players);
				applyPingColor();
				//sortPlayerList();
				break;

			case 'updatePing':
				updatePing(event.data.players);
				applyPingColor();
				break;

			case 'updateServerInfo':
				if (event.data.maxPlayers) {
					$('#max_players').html(event.data.maxPlayers);
				}
				
				$('#queue').html(event.data.queue);

				if (event.data.uptime) {
					$('#server_uptime').html(event.data.uptime);
				}

				if (event.data.playTime) {
					$('#play_time').html(event.data.playTime);
				}

				break;

			default:
				console.log('esx_scoreboard: unknown action!');
				break;
		}
	}, false);
});

function applyPingColor() {
	$('#playerlist tr').each(function () {
		$(this).find('.ping').each(function () {
			var ping = $(this).html();
			var color = 'lightblue';

			if (ping > 50 && ping < 80) {
				color = 'lightblue';
			} else if (ping >= 80) {
				color = 'red';
			}

			$(this).css('#fffff', color);
			$(this).html(ping + " ms");
		});

	});
}

// Todo: not the best code
function updatePing(players) {
	jQuery.each(players, function (i, v) {
		if (v != null) {
			$('#playerlist tr:not(.heading)').each(function () {
				$(this).find('.pid:contains(' + v.id + ')').each(function () {
					$(this).parent().find('.ping').html(v.ping);
				});
			});
		}
	});
}

function sortPlayerList() {
	var table = $('#playerlist'),
		rows = $('tr:not(.heading)', table);

	rows.sort(function(a, b) {
		var keyA = $('td', a).eq(1).html();
		var keyB = $('td', b).eq(1).html();

		return (keyA - keyB);
	});

	rows.each(function(index, row) {
		table.append(row);
	});
}
