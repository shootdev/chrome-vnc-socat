function renderProxyConfig(config) {
    document.getElementById('username').textContent = config.username || '';
    document.getElementById('password').textContent = config.password || '';
    document.getElementById('host').textContent = config.host || '';
    document.getElementById('port').textContent = config.port || '';
    document.getElementById('proxyEnabled').textContent = config.enabled;
    document.getElementById('toggleProxy').textContent = config.enabled ? '关闭代理' : '开启代理';
}

function requestProxyConfig() {
    chrome.runtime.sendMessage({action: 'getProxyConfig'}, function(response) {
        if (!response || !response.success) {
            document.getElementById('proxyEnabled').textContent = '读取失败';
            return;
        }
        renderProxyConfig(response.config);
    });
}

document.addEventListener('DOMContentLoaded', function() {
    requestProxyConfig();
    document.getElementById('toggleProxy').addEventListener('click', function() {
        chrome.runtime.sendMessage({action: 'toggleProxy'}, function(response) {
            if (response && response.success) {
                requestProxyConfig();
            }
        });
    });
});
