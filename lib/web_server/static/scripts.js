// Function to render requests for a specific page
// Function to render requests for a specific page
async function renderRequests(page, pageSize, searchQuery = '') {
    const requestsList = document.getElementById('requests-list');
    const requestTemplate = document.getElementById('request-template');
    const paginationInfo = document.getElementById('pagination-info');
    const prevPageButton = document.getElementById('prev-page');
    const nextPageButton = document.getElementById('next-page');
    const noResultsText = document.getElementById('no-results-text');

    requestsList.innerHTML = '';

    try {
        let url = `/requests?page=${page}&pageSize=${pageSize}`;
        if (searchQuery) {
            url += `&search=${encodeURIComponent(searchQuery)}`;
        }

        const response = await fetch(url);
        const responseData = await response.json();
        const requestData = responseData.requests;

        requestData.forEach((request, index) => {
            const clone = requestTemplate.content.cloneNode(true);
            const srNoElement = clone.querySelector('.sr-no');
            const nameElement = clone.querySelector('.name');

            srNoElement.textContent = (page - 1) * pageSize + index + 1;
            nameElement.textContent = request.name;
            nameElement.href = request.profileLink;

            requestsList.appendChild(clone);
        });

        const totalItems = responseData.totalItems;
        const startIndex = (page - 1) * pageSize + 1;
        const endIndex = Math.min(startIndex + pageSize - 1, totalItems);
        paginationInfo.textContent = `${startIndex}-${endIndex} of ${totalItems}`;

        prevPageButton.disabled = page === 1;
        nextPageButton.disabled = endIndex === totalItems;

        const resultsFound = requestData.length > 0;
        noResultsText.style.display = resultsFound ? 'none' : 'block';

    } catch (error) {
        console.error('Error fetching requests:', error);
    }
}

// Function to handle search
async function handleSearch() {
    const searchQuery = document.getElementById('search-input').value.trim();
    await renderRequests(1, PAGE_SIZE, searchQuery);
}

document.getElementById('next-page').addEventListener('click', () => {
    currentPage++;
    renderRequests(currentPage, PAGE_SIZE, document.getElementById('search-input').value.trim());
});

document.getElementById('prev-page').addEventListener('click', () => {
    if (currentPage > 1) {
        currentPage--;
        renderRequests(currentPage, PAGE_SIZE, document.getElementById('search-input').value.trim());
    }
});

const PAGE_SIZE = 10; // Number of items per page
let currentPage = 1; // Current page

document.getElementById('search-input').addEventListener('input', handleSearch);

handleSearch();
