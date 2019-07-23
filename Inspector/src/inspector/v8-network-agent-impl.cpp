#include "v8-network-agent-impl.h"

namespace v8_inspector {
    
namespace NetworkAgentState {
    static const char networkEnabled[] = "networkEnabled";
}

V8NetworkAgentImpl::V8NetworkAgentImpl(V8InspectorSessionImpl* session, protocol::FrontendChannel* frontendChannel, protocol::DictionaryValue* state)
    : m_session(session),
      m_frontend(frontendChannel),
      m_state(state),
      m_enabled(false) {
}

V8NetworkAgentImpl::~V8NetworkAgentImpl() {
}

DispatchResponse V8NetworkAgentImpl::enable(Maybe<int> in_maxTotalBufferSize, Maybe<int> in_maxResourceBufferSize, Maybe<int> in_maxPostDataSize) {
    if (m_enabled) {
        return DispatchResponse::OK();
    }
    
    m_state->setBoolean(NetworkAgentState::networkEnabled, true);
    
    m_enabled = true;
    
    return DispatchResponse::OK();
}
    
DispatchResponse V8NetworkAgentImpl::disable() {
    if (!m_enabled) {
        return DispatchResponse::OK();
    }
    
    m_state->setBoolean(NetworkAgentState::networkEnabled, false);
    
    m_enabled = false;
    
    return DispatchResponse::OK();
}
    
DispatchResponse V8NetworkAgentImpl::canClearBrowserCache(bool* out_result) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}
    
DispatchResponse V8NetworkAgentImpl::canClearBrowserCookies(bool* out_result) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}
    
DispatchResponse V8NetworkAgentImpl::emulateNetworkConditions(bool in_offline, double in_latency, double in_downloadThroughput, double in_uploadThroughput, Maybe<String> in_connectionType) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

void V8NetworkAgentImpl::getResponseBody(const String& in_requestId, std::unique_ptr<GetResponseBodyCallback> callback) {
}

void V8NetworkAgentImpl::getRequestPostData(const String& in_requestId, std::unique_ptr<GetRequestPostDataCallback> callback) {
}
    
DispatchResponse V8NetworkAgentImpl::searchInResponseBody(const String& in_requestId, const String& in_query, Maybe<bool> in_caseSensitive, Maybe<bool> in_isRegex, std::unique_ptr<protocol::Array<protocol::Debugger::SearchMatch>>* out_result) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

DispatchResponse V8NetworkAgentImpl::setBypassServiceWorker(bool in_bypass) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

DispatchResponse V8NetworkAgentImpl::getCertificate(const String& in_origin, std::unique_ptr<protocol::Array<String>>* out_tableNames) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}
    
DispatchResponse V8NetworkAgentImpl::setCacheDisabled(bool in_cacheDisabled) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

DispatchResponse V8NetworkAgentImpl::setDataSizeLimitsForTest(int in_maxTotalSize, int in_maxResourceSize) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}
    
DispatchResponse V8NetworkAgentImpl::replayXHR(const String& in_requestId) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

DispatchResponse V8NetworkAgentImpl::setBlockedURLs(std::unique_ptr<protocol::Array<String>> in_urls) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

DispatchResponse V8NetworkAgentImpl::setExtraHTTPHeaders(std::unique_ptr<protocol::Network::Headers> in_headers) {
    return protocol::DispatchResponse::Error("Protocol command not supported.");
}

}
