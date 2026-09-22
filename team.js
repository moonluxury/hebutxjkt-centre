// Team list scrolling and email copying.
(() => {
    const grid = document.getElementById('team-grid');
    if (!grid) return;

    const keepScrollInGrid = (event) => {
        if (grid.scrollHeight > grid.clientHeight + 1 || grid.scrollWidth > grid.clientWidth + 1) {
            event.stopPropagation();
        }
    };

    for (const type of ['wheel', 'touchstart', 'touchend']) {
        grid.addEventListener(type, keepScrollInGrid, { passive: true });
    }

    grid.addEventListener('keydown', (event) => {
        if (['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', ' '].includes(event.key)) {
            keepScrollInGrid(event);
        }
    });

    const status = document.getElementById('team-copy-status');
    let statusTimeout;

    const copyWithSelection = (email) => {
        const previousFocus = document.activeElement;
        const field = document.createElement('textarea');
        field.value = email;
        field.setAttribute('readonly', '');
        field.style.cssText = 'position:fixed;top:0;left:0;opacity:0;font-size:16px;pointer-events:none;';
        document.body.appendChild(field);

        try {
            field.focus({ preventScroll: true });
            field.select();
            if (!document.execCommand('copy')) throw new Error('Copy failed');
        } finally {
            field.remove();
            previousFocus?.focus({ preventScroll: true });
        }
    };

    const copyEmail = async (email) => {
        if (navigator.clipboard?.writeText) {
            try {
                await navigator.clipboard.writeText(email);
                return;
            } catch {
                // Try a selection-based copy if clipboard access is unavailable.
            }
        }
        copyWithSelection(email);
    };

    const showStatus = (message) => {
        if (!status) return;
        clearTimeout(statusTimeout);
        status.textContent = message;
        statusTimeout = setTimeout(() => { status.textContent = ''; }, 5000);
    };

    grid.addEventListener('click', async (event) => {
        const button = event.target.closest('button.team-email[data-email]');
        if (!button || !grid.contains(button)) return;
        const email = button.dataset.email;
        if (!email) return;

        try {
            await copyEmail(email);
            showStatus(`邮箱已复制：${email}`);
        } catch {
            showStatus('复制未成功，请选中邮箱手动复制。');
        }
    });
})();
