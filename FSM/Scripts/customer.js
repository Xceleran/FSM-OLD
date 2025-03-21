document.addEventListener('DOMContentLoaded', () => {
    // Modal Handlers
    function openModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'flex'; // Show modal
        }
    }

    function closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none'; // Hide modal
        }
    }

    // Add Customer
    const addCustomerBtn = document.getElementById('addCustomerBtn');
    if (addCustomerBtn) {
        addCustomerBtn.addEventListener('click', () => openModal('addCustomerModal'));
    }

    const closeAddCustomerBtn = document.getElementById('closeAddCustomer');
    if (closeAddCustomerBtn) {
        closeAddCustomerBtn.addEventListener('click', () => closeModal('addCustomerModal'));
    }

    const addCustomerForm = document.getElementById('addCustomerForm');
    if (addCustomerForm) {
        addCustomerForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const customer = {
                name: formData.get('name'),
                email: formData.get('email'),
                phone: formData.get('phone')
            };
            addCustomerToList(customer);
            closeModal('addCustomerModal');
            e.target.reset();
        });
    }

    function addCustomerToList(customer) {
        const id = Date.now();
        const list = document.getElementById('customerList');
        if (list) {
            const item = document.createElement('div');
            item.className = 'cust-item'; // Use unique class
            item.dataset.id = id;
            item.innerHTML = `
                <div class="cust-item-field"><span class="cust-item-label">Name: </span>${customer.name}</div>
                <div class="cust-item-field"><span class="cust-item-label">Email: </span>${customer.email}</div>
                <div class="cust-item-field"><span class="cust-item-label">Sites: </span>0</div>
            `;
            list.appendChild(item);
            item.addEventListener('click', () => selectCustomer(item, id, customer));
        }
    }

    // Edit Customer
    const editCustomerBtn = document.getElementById('editCustomerBtn');
    if (editCustomerBtn) {
        editCustomerBtn.addEventListener('click', () => {
            const name = document.getElementById('customerName').textContent;
            const email = document.getElementById('customerEmail').textContent;
            const phone = document.getElementById('customerPhone').textContent;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editPhone').value = phone;
            openModal('editCustomerModal');
        });
    }

    const closeEditCustomerBtn = document.getElementById('closeEditCustomer');
    if (closeEditCustomerBtn) {
        closeEditCustomerBtn.addEventListener('click', () => closeModal('editCustomerModal'));
    }

    const editCustomerForm = document.getElementById('editCustomerForm');
    if (editCustomerForm) {
        editCustomerForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            document.getElementById('customerName').textContent = formData.get('name');
            document.getElementById('customerEmail').textContent = formData.get('email');
            document.getElementById('customerPhone').textContent = formData.get('phone');
            const activeItem = document.querySelector('.cust-item-active');
            if (activeItem) {
                activeItem.children[0].textContent = `Name: ${formData.get('name')}`; // Update with label
                activeItem.children[1].textContent = `Email: ${formData.get('email')}`; // Update with label
            }
            closeModal('editCustomerModal');
        });
    }

    // Add Site
    const addSiteBtn = document.getElementById('addSiteBtn');
    if (addSiteBtn) {
        addSiteBtn.addEventListener('click', () => openModal('addSiteModal'));
    }

    const closeAddSiteBtn = document.getElementById('closeAddSite');
    if (closeAddSiteBtn) {
        closeAddSiteBtn.addEventListener('click', () => closeModal('addSiteModal'));
    }

    const addSiteForm = document.getElementById('addSiteForm');
    if (addSiteForm) {
        addSiteForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const formData = new FormData(e.target);
            const site = {
                name: formData.get('siteName'),
                address: formData.get('address'),
                equipment: formData.get('equipment'),
                status: formData.get('status') || 'Active',
                pictures: Array.from(formData.getAll('pictures')).map(file => URL.createObjectURL(file))
            };
            addSiteToList(site);
            closeModal('addSiteModal');
            e.target.reset();
        });
    }

    function addSiteToList(site) {
        const id = Date.now();
        const list = document.getElementById('sites');
        if (list) {
            const card = document.createElement('div');
            card.className = 'cust-site-card'; // Use unique class
            card.dataset.siteId = id;
            card.innerHTML = `
                <h3 class="cust-site-title">${site.name}</h3>
                <p class="cust-site-info">${site.address}</p>
                <p class="cust-site-info">Equipment: ${site.equipment || 'None'}</p>
                <div class="cust-site-actions">
                    <button class="cust-site-edit-btn" data-site-id="${id}">Edit</button>
                    <a href="CustomerDetails.aspx?siteId=${id}" class="cust-site-view-link">View Details</a>
                </div>
            `;
            list.insertBefore(card, document.getElementById('addSiteBtn'));
            card.querySelector('.cust-site-edit-btn').addEventListener('click', () => editSite(id, site));
            updateSiteCount();
        }
    }

    // Edit Site
    function editSite(siteId, siteData) {
        document.getElementById('editSiteName').value = siteData.name;
        document.getElementById('editSiteAddress').value = siteData.address;
        document.getElementById('editSiteEquipment').value = siteData.equipment || '';
        openModal('editSiteModal');
        const editSiteForm = document.getElementById('editSiteForm');
        if (editSiteForm) {
            editSiteForm.onsubmit = (e) => {
                e.preventDefault();
                const formData = new FormData(e.target);
                const card = document.querySelector(`.cust-site-card[data-site-id="${siteId}"]`);
                if (card) {
                    card.children[0].textContent = formData.get('siteName');
                    card.children[1].textContent = formData.get('address');
                    card.children[2].textContent = `Equipment: ${formData.get('equipment') || 'None'}`;
                    siteData.name = formData.get('siteName');
                    siteData.address = formData.get('address');
                    siteData.equipment = formData.get('equipment');
                    siteData.pictures = formData.getAll('pictures').length
                        ? Array.from(formData.getAll('pictures')).map(file => URL.createObjectURL(file))
                        : siteData.pictures || [];
                    closeModal('editSiteModal');
                    updateSiteCount();
                }
            };
        }
    }

    const closeEditSiteBtn = document.getElementById('closeEditSite');
    if (closeEditSiteBtn) {
        closeEditSiteBtn.addEventListener('click', () => closeModal('editSiteModal'));
    }

    // Search Customers
    const customerSearch = document.getElementById('customerSearch');
    if (customerSearch) {
        customerSearch.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            const items = document.querySelectorAll('.cust-item');
            items.forEach(item => {
                const name = item.children[0].textContent.replace('Name: ', '').toLowerCase();
                const email = item.children[1].textContent.replace('Email: ', '').toLowerCase();
                item.style.display = name.includes(query) || email.includes(query) ? '' : 'none';
            });
        });
    }

    // Select Customer
    const customerItems = document.querySelectorAll('.cust-item');
    if (customerItems) {
        customerItems.forEach(item => {
            item.addEventListener('click', () => selectCustomer(item, item.dataset.id));
        });
    }

    function selectCustomer(item, id) {
        customerItems.forEach(i => i.classList.remove('cust-item-active'));
        item.classList.add('cust-item-active');
        const data = {
            1: { name: 'John Doe', email: 'john.doe@email.com', phone: '(555) 123-4567' },
            2: { name: 'ABC Property Mgmt', email: 'abc@propertymgmt.com', phone: '(555) 987-6543' }
        };
        const customer = data[id] || {
            name: item.children[0].textContent.replace('Name: ', ''),
            email: item.children[1].textContent.replace('Email: ', ''),
            phone: ''
        };
        document.getElementById('customerName').textContent = customer.name;
        document.getElementById('customerEmail').textContent = customer.email;
        document.getElementById('customerPhone').textContent = customer.phone || 'N/A';
    }

    // Accordion Functionality
    const accordionButtons = document.querySelectorAll('.cust-section-toggle');
    if (accordionButtons) {
        accordionButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const sectionId = btn.dataset.section;
                const content = document.getElementById(sectionId);
                const isActive = content.style.display === 'block';
                accordionButtons.forEach(b => {
                    const sectionContent = document.getElementById(b.dataset.section);
                    if (sectionContent) {
                        sectionContent.style.display = 'none';
                    }
                });
                if (!isActive) {
                    content.style.display = 'block';
                }
            });
        });
    }

    // Message Customer
    const messageCustomerBtn = document.getElementById('messageCustomerBtn');
    if (messageCustomerBtn) {
        messageCustomerBtn.addEventListener('click', () => {
            const email = document.getElementById('customerEmail').textContent;
            alert(`Sending message to ${email}...`);
        });
    }

    // Custom Status Tags
    const statusTags = document.getElementById('statusTags');
    if (statusTags) {
        const savedTags = JSON.parse(localStorage.getItem('statusTags')) || [
            { name: 'Active', color: '#e5e7eb' },
            { name: 'Pending', color: '#e5e7eb' }
        ];

        function saveTags() {
            const tags = Array.from(document.querySelectorAll('.cust-status-tag')).map(tag => ({
                name: tag.dataset.tag,
                color: tag.style.backgroundColor || '#e5e7eb'
            }));
            localStorage.setItem('statusTags', JSON.stringify(tags));
        }

        const colorPickerModal = document.createElement('div');
        colorPickerModal.id = 'colorPickerModal';
        colorPickerModal.style.cssText = 'display: none; position: absolute; background-color: #ffffff; border: 1px solid #d1d5db; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); border-radius: 8px; padding: 8px; z-index: 50;';
        colorPickerModal.innerHTML = `
            <input type="color" id="colorPickerInput" style="width: 100%; height: 40px;">
            <button id="closeColorPicker" style="margin-top: 8px; width: 100%; background-color: #e5e7eb; color: #374151; padding: 4px 8px; border-radius: 4px; border: none; cursor: pointer;">Close</button>
        `;
        document.body.appendChild(colorPickerModal);

        const colorPickerInput = document.getElementById('colorPickerInput');
        const closeColorPickerBtn = document.getElementById('closeColorPicker');

        function createTag(tagName, color = '#e5e7eb') {
            const tag = document.createElement('span');
            tag.className = 'cust-status-tag'; // Use unique class
            tag.dataset.tag = tagName.toLowerCase();
            tag.style.backgroundColor = color;
            tag.style.color = getContrastColor(color);
            tag.innerHTML = `${tagName}<button class="cust-tag-delete">×</button>`;

            tag.addEventListener('click', (e) => {
                if (e.target.classList.contains('cust-tag-delete')) return;
                tag.classList.toggle('active');
                const isActive = tag.classList.contains('active');
                tag.style.backgroundColor = isActive ? darkenColor(color) : color;
                tag.style.color = getContrastColor(tag.style.backgroundColor);

                if (!isActive) {
                    showColorPicker(tag, color);
                } else {
                    colorPickerModal.style.display = 'none';
                }
            });

            const deleteBtn = tag.querySelector('.cust-tag-delete');
            deleteBtn.addEventListener('click', () => {
                tag.remove();
                saveTags();
            });

            return tag;
        }

        function showColorPicker(tag, currentColor) {
            colorPickerInput.value = rgbToHex(currentColor);
            colorPickerModal.style.display = 'block';

            const rect = tag.getBoundingClientRect();
            const scrollTop = window.scrollY || document.documentElement.scrollTop;
            const scrollLeft = window.scrollX || document.documentElement.scrollLeft;

            colorPickerModal.style.top = `${rect.bottom + scrollTop + 5}px`;
            colorPickerModal.style.left = `${rect.left + scrollLeft}px`;

            const modalRect = colorPickerModal.getBoundingClientRect();
            if (modalRect.right > window.innerWidth) {
                colorPickerModal.style.left = `${window.innerWidth - modalRect.width + scrollLeft}px`;
            }
            if (modalRect.bottom > window.innerHeight) {
                colorPickerModal.style.top = `${rect.top + scrollTop - modalRect.height - 5}px`;
            }

            colorPickerInput.oninput = () => {
                const newColor = colorPickerInput.value;
                tag.style.backgroundColor = newColor;
                tag.style.color = getContrastColor(newColor);
                saveTags();
            };
        }

        closeColorPickerBtn.addEventListener('click', () => {
            colorPickerModal.style.display = 'none';
        });

        document.addEventListener('click', (e) => {
            if (!colorPickerModal.contains(e.target) && !e.target.closest('.cust-status-tag')) {
                colorPickerModal.style.display = 'none';
            }
        });

        function getContrastColor(hexColor) {
            const rgb = hexToRgb(hexColor);
            const luminance = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255;
            return luminance > 0.5 ? '#000000' : '#ffffff';
        }

        function hexToRgb(hex) {
            const bigint = parseInt(hex.replace('#', ''), 16);
            return {
                r: (bigint >> 16) & 255,
                g: (bigint >> 8) & 255,
                b: bigint & 255
            };
        }

        function rgbToHex(rgb) {
            if (rgb.startsWith('#')) return rgb;
            const [r, g, b] = rgb.match(/\d+/g).map(Number);
            return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
        }

        function darkenColor(hex) {
            const rgb = hexToRgb(hex);
            const factor = 0.8;
            return `rgb(${Math.round(rgb.r * factor)}, ${Math.round(rgb.g * factor)}, ${Math.round(rgb.b * factor)})`;
        }

        savedTags.forEach(tag => statusTags.appendChild(createTag(tag.name, tag.color)));

        const addTagBtn = document.getElementById('addTagBtn');
        if (addTagBtn) {
            addTagBtn.addEventListener('click', () => {
                const input = document.getElementById('newTagInput');
                const tagName = input.value.trim();
                if (tagName && !Array.from(statusTags.children).some(tag => tag.dataset.tag === tagName.toLowerCase())) {
                    const tag = createTag(tagName);
                    statusTags.appendChild(tag);
                    saveTags();
                    input.value = '';
                }
            });
        }
    }

    // Helper: Update Site Count
    function updateSiteCount() {
        const activeItem = document.querySelector('.cust-item-active');
        const siteCount = document.querySelectorAll('.cust-site-card').length;
        if (activeItem) {
            activeItem.children[2].textContent = `Sites: ${siteCount}`; // Update with label
        }
    }

    // Initial Event Listeners for Existing Sites
    document.querySelectorAll('.cust-site-edit-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const siteId = btn.dataset.siteId;
            const card = btn.closest('.cust-site-card');
            if (card) {
                editSite(siteId, {
                    name: card.children[0].textContent,
                    address: card.children[1].textContent,
                    equipment: card.children[2].textContent.replace('Equipment: ', '')
                });
            }
        });
    });
});