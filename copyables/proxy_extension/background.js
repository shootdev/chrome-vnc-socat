var username = "";
var password = "";
var host = "";
var port = 11065;
var proxyEnabled = false; // 默认禁用代理

function setProxy(host, port, username, password) {
    var config = {
        mode: "fixed_servers",
        rules: {
            singleProxy: {
                scheme: "http",
                host: host,
                port: port
            },
            bypassList: ["localhost"]
        }
    };

    chrome.proxy.settings.set({value: config, scope: "regular"}, function() {});
}

function callbackFn(details) {
    return {
        authCredentials: {
            username: username,
            password: password
        }
    };
}

chrome.webRequest.onAuthRequired.addListener(
    callbackFn,
    {urls: ["<all_urls>"]},
    ['blocking']
);

chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (message === "getCredentials") {
        sendResponse({
            username: username,
            password: password,
            host: host,
            port: port,
            proxyEnabled: proxyEnabled
        });
    } else if (message.action === "updateCredentials") {
        username = message.username;
        password = message.password;
        host = message.host;
        port = message.port;
        proxyEnabled = true;

        setProxy(host, port, username, password);
        sendResponse({ success: true });
    } else if (message.action === "toggleProxy") {
        if (!host || !port || !username || !password) {
            sendResponse({ error: "请先输入代理信息" });
            return;
        }
        proxyEnabled = !proxyEnabled;
        if (proxyEnabled) {
            setProxy(host, port, username, password);
        } else {
            useSystemProxy();
        }
        sendResponse({ proxyEnabled: proxyEnabled });
    }
    return true;
});


function useSystemProxy() {
    chrome.proxy.settings.clear({scope: "regular"}, function() {
        console.log("Proxy settings cleared. Now using the system's proxy.");
    });
}

if (proxyEnabled) {
    setProxy(host, port, username, password);
} else {
    useSystemProxy();
}
