/**
 * 백오피스 공통 모듈
 * - API base URL, 토큰 저장, 로그인 체크, 탭 전환
 */
const Admin = (function () {
    const API_BASE = '/api';
    const TOKEN_KEY = 'admin_access_token';

    function getToken() {
        return localStorage.getItem(TOKEN_KEY);
    }

    function setToken(token) {
        if (token) {
            localStorage.setItem(TOKEN_KEY, token);
        } else {
            localStorage.removeItem(TOKEN_KEY);
        }
    }

    function isLoggedIn() {
        return !!getToken();
    }

    function logout() {
        setToken(null);
        showLoginScreen();
    }

    async function apiRequest(url, options = {}) {
        const token = getToken();
        const headers = {
            'Content-Type': 'application/json',
            ...(options.headers || {}),
        };
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        const response = await fetch(API_BASE + url, {
            ...options,
            headers,
        });

        if (response.status === 401) {
            setToken(null);
            showLoginScreen();
            throw new Error('인증이 만료되었습니다.');
        }

        const data = await response.json().catch(() => ({}));
        if (!response.ok) {
            throw new Error(data.message || `요청 실패: ${response.status}`);
        }
        return data;
    }

    function showLoginScreen() {
        document.getElementById('login-screen').classList.remove('hidden');
        document.getElementById('admin-screen').classList.add('hidden');
    }

    function showAdminScreen() {
        document.getElementById('login-screen').classList.add('hidden');
        document.getElementById('admin-screen').classList.remove('hidden');
    }

    function switchTab(tabId) {
        document.querySelectorAll('.nav-tab').forEach((btn) => btn.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach((content) => content.classList.remove('active'));

        const activeBtn = document.querySelector(`[data-tab="${tabId}"]`);
        const activeContent = document.getElementById(`tab-${tabId}`);
        if (activeBtn) activeBtn.classList.add('active');
        if (activeContent) activeContent.classList.add('active');

        if (typeof window[`load${tabId.charAt(0).toUpperCase() + tabId.slice(1)}`] === 'function') {
            window[`load${tabId.charAt(0).toUpperCase() + tabId.slice(1)}`]();
        }
    }

    function initTabs() {
        document.querySelectorAll('.nav-tab').forEach((btn) => {
            btn.addEventListener('click', () => {
                const tabId = btn.getAttribute('data-tab');
                switchTab(tabId);
            });
        });
    }

    async function login(email, password) {
        const data = await apiRequest('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password }),
        });
        if (data.success && data.data?.accessToken) {
            setToken(data.data.accessToken);
            showAdminScreen();
            switchTab('dashboard');
            return true;
        }
        throw new Error(data.message || '로그인 실패');
    }

    return {
        getToken,
        setToken,
        isLoggedIn,
        logout,
        apiRequest,
        showLoginScreen,
        showAdminScreen,
        switchTab,
        initTabs,
        login,
    };
})();
