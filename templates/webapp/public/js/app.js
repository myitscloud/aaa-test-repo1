/**
 * Main Application JavaScript
 */

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', () => {
    console.log('Application initialized');
    init();
});

/**
 * Initialize the application
 */
function init() {
    // Add your initialization code here
}

/**
 * Example utility function
 * @param {string} elementId - The ID of the element
 * @returns {HTMLElement|null} The element or null
 */
function getElement(elementId) {
    return document.getElementById(elementId);
}

/**
 * Example API fetch function
 * @param {string} url - The API endpoint
 * @returns {Promise<object>} The response data
 */
async function fetchData(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Fetch error:', error);
        throw error;
    }
}
