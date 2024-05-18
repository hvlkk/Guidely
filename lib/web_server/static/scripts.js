document.addEventListener('DOMContentLoaded', () => {
    const PAGE_SIZE = 10; // Number of items per page
    let currentPage = 1; // Current page

    const requestsList = document.getElementById('requests-list');
    const requestTemplate = document.getElementById('request-template');
    const paginationInfo = document.getElementById('pagination-info');
    const prevPageButton = document.getElementById('prev-page');
    const nextPageButton = document.getElementById('next-page');
    const noResultsText = document.getElementById('no-results-text');
    const searchInput = document.getElementById('search-input');

    const popupBox = document.getElementById('popup-box');
    const popupName = document.getElementById('popup-name');
    const popupEmail = document.getElementById('popup-email');
    const popupMessage = document.getElementById('popup-message');
    const closeBtn = document.querySelector('.close-btn');

    async function renderRequests(page, pageSize, searchQuery = '') {
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
                nameElement.dataset.index = index; // Add index to the link for reference

                nameElement.addEventListener('click', (event) => {
                    event.preventDefault();
                    showPopup(request);
                });

                requestsList.appendChild(clone);
            });

            const totalItems = responseData.totalItems;
            const startIndex = (page - 1) * pageSize + 1;
            const endIndex = Math.min(startIndex + pageSize - 1, totalItems);
            paginationInfo.textContent = `${startIndex}-${endIndex} of ${totalItems}`;

            prevPageButton.disabled = page === 1;
            nextPageButton.disabled = endIndex === totalItems;

            noResultsText.style.display = requestData.length > 0 ? 'none' : 'block';

        } catch (error) {
            console.error('Error fetching requests:', error);
        }
    }

    function showPopup(request) {
        popupName.textContent = request.name;
        popupEmail.textContent = request.email;
        popupMessage.textContent = request.message;
        popupBox.style.display = 'block';
    }

    closeBtn.addEventListener('click', () => {
        popupBox.style.display = 'none';
    });

    window.addEventListener('click', (event) => {
        if (event.target === popupBox) {
            popupBox.style.display = 'none';
        }
    });

    searchInput.addEventListener('input', () => {
        renderRequests(1, PAGE_SIZE, searchInput.value.trim());
    });

    prevPageButton.addEventListener('click', () => {
        if (currentPage > 1) {
            currentPage--;
            renderRequests(currentPage, PAGE_SIZE, searchInput.value.trim());
        }
    });

    nextPageButton.addEventListener('click', () => {
        currentPage++;
        renderRequests(currentPage, PAGE_SIZE, searchInput.value.trim());
    });

    renderRequests(currentPage, PAGE_SIZE);
});
