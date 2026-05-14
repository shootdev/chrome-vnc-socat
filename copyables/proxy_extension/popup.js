document.addEventListener("DOMContentLoaded", function() {
    chrome.runtime.sendMessage("getCredentials", function(response) {
        document.getElementById('username').textContent = response.username;
        document.getElementById('password').textContent = response.password;
        document.getElementById('host').textContent = response.host;
        document.getElementById('port').textContent = response.port;
        document.getElementById('proxyEnabled').textContent = response.proxyEnabled;

        const toggleButton = document.getElementById('toggleProxy');
        toggleButton.textContent = response.proxyEnabled ? "关闭代理" : "开启代理";

        toggleButton.addEventListener("click", function() {
            chrome.runtime.sendMessage({ action: "toggleProxy" }, function(updatedResponse) {
                document.getElementById('proxyEnabled').textContent = updatedResponse.proxyEnabled;
                toggleButton.textContent = updatedResponse.proxyEnabled ? "关闭代理" : "开启代理";
            });
        });
    });
});
