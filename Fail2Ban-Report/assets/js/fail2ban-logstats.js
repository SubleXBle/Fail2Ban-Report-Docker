async function fetchAndDisplayLogStats() {
  const bansElement = document.getElementById('fail2ban-bans');
  const unbansElement = document.getElementById('fail2ban-unbans');
  const totalElement = document.getElementById('fail2ban-total');

  const yesterdayElement = document.getElementById('fail2ban-yesterday');
  const last7Element = document.getElementById('fail2ban-last7');
  const last30Element = document.getElementById('fail2ban-last30');

  try {
    const response = await fetch('includes/fail2ban-logstats.php');
    if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
    const statsData = await response.json();

    // Heute
    bansElement.textContent = `${statsData.ban_count} with ${statsData.ban_unique_ips} unique IPs`;
    unbansElement.textContent = `${statsData.unban_count} with ${statsData.unban_unique_ips} unique IPs`;
    totalElement.textContent = `${statsData.total_events} events with ${statsData.total_unique_ips} unique IPs`;

    // Aggregiert
    if (statsData.aggregated) {
      const aggr = statsData.aggregated;

      yesterdayElement.textContent = `${aggr.yesterday.total_events} events (🚫 ${aggr.yesterday.ban_count}, 🟢 ${aggr.yesterday.unban_count}): ${aggr.yesterday.total_unique_ips} IPs`;
      last7Element.textContent = `${aggr.last_7_days.total_events} events (🚫 ${aggr.last_7_days.ban_count}, 🟢 ${aggr.last_7_days.unban_count}) : ${aggr.last_7_days.total_unique_ips} IPs`;
      last30Element.textContent = `${aggr.last_30_days.total_events} events (🚫 ${aggr.last_30_days.ban_count}, 🟢 ${aggr.last_30_days.unban_count}) : ${aggr.last_30_days.total_unique_ips} IPs`;
    }

  } catch (err) {
    bansElement.textContent = '--';
    unbansElement.textContent = '--';
    totalElement.textContent = '--';
    if (yesterdayElement) yesterdayElement.textContent = '--';
    if (last7Element) last7Element.textContent = '--';
    if (last30Element) last30Element.textContent = '--';
    console.error('Error loading Fail2Ban stats:', err);
  }
}

document.addEventListener('DOMContentLoaded', fetchAndDisplayLogStats);
