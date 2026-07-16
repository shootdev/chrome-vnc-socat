importScripts('proxy_config.js');

let proxyConfig = RPA_PROXY_CONFIG;

function normalizeProxyConfig(config) {
    return {
        enabled: Boolean(config && config.enabled),
        username: String((config && config.username) || ''),
        password: String((config && config.password) || ''),
        host: String((config && config.host) || ''),
        port: Number((config && config.port) || 0)
    };
}

function getProxyRules(config) {
    return {
        mode: 'fixed_servers',
        rules: {
            singleProxy: {
                scheme: 'http',
                host: config.host,
                port: config.port
            },
            bypassList: ['localhost']
        }
    };
}

async function applyProxyConfig(config) {
    proxyConfig = normalizeProxyConfig(config);
    if (proxyConfig.enabled) {
        if (!proxyConfig.host || !proxyConfig.port) {
            throw new Error('代理地址不能为空');
        }
        await chrome.proxy.settings.set({value: getProxyRules(proxyConfig), scope: 'regular'});
    } else {
        await chrome.proxy.settings.clear({scope: 'regular'});
    }
    return {enabled: proxyConfig.enabled, host: proxyConfig.host, port: proxyConfig.port};
}

function applyInitialProxyConfig() {
    applyProxyConfig(RPA_PROXY_CONFIG).catch(console.error);
}

chrome.runtime.onInstalled.addListener(applyInitialProxyConfig);
chrome.runtime.onStartup.addListener(applyInitialProxyConfig);

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (!message) {
        return false;
    }
    if (message.action === 'getProxyConfig') {
        sendResponse({
            success: true,
            config: {
                enabled: proxyConfig.enabled,
                username: proxyConfig.username,
                password: proxyConfig.password,
                host: proxyConfig.host,
                port: proxyConfig.port
            }
        });
        return false;
    }
    if (message.action === 'toggleProxy') {
        applyProxyConfig({...proxyConfig, enabled: !proxyConfig.enabled})
            .then((config) => sendResponse({success: true, config: config}))
            .catch((error) => sendResponse({success: false, error: error.message}));
        return true;
    }
    if (message.action !== 'setProxyConfig') {
        return false;
    }
    applyProxyConfig(message.proxy)
        .then((config) => sendResponse({success: true, config: config}))
        .catch((error) => sendResponse({success: false, error: error.message}));
    return true;
});

chrome.webRequest.onAuthRequired.addListener(
    (details, callback) => {
        if (!details.isProxy || !proxyConfig.enabled || !proxyConfig.username || !proxyConfig.password) {
            callback({});
            return;
        }
        callback({
            authCredentials: {
                username: proxyConfig.username,
                password: proxyConfig.password
            }
        });
    },
    {urls: ['<all_urls>']},
    ['asyncBlocking']
);
