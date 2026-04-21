// Premium Interactivity for Dynamic Workspaces

document.addEventListener('DOMContentLoaded', () => {
    const navbar = document.getElementById('navbar');
    const heroContent = document.querySelector('.hero-content');
    const heroImage = document.querySelector('.hero-image');
    
    // Navbar Scroll Effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Parallax Effect on Hero Image
    window.addEventListener('scroll', () => {
        const offset = window.pageYOffset;
        if (heroImage) {
            heroImage.style.backgroundPositionY = `${offset * 0.5}px`;
        }
    });

    // Reveal on Scroll using Intersection Observer
    const revealOptions = {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px"
    };

    const revealObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('reveal');
                observer.unobserve(entry.target);
            }
        });
    }, revealOptions);

    // Elements to reveal
    const revealElements = [
        '.section-title', 
        '.location-card', 
        '.service-item', 
        '.trust-item'
    ];

    revealElements.forEach(selector => {
        document.querySelectorAll(selector).forEach(el => {
            el.style.opacity = '0';
            revealObserver.observe(el);
        });
    });

    // Smooth Scrolling for links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 125, // Offset for new fixed nav height
                    behavior: 'smooth'
                });
            }
        });
    });
    // Mobile Menu Toggle
    const navToggle = document.getElementById('navToggle');
    const navLinks = document.querySelector('.nav-links');

    if (navToggle && navLinks) {
        navToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            navLinks.classList.toggle('active');
            const icon = navToggle.querySelector('i');
            if (navLinks.classList.contains('active')) {
                icon.classList.replace('fa-bars', 'fa-times');
            } else {
                icon.classList.replace('fa-times', 'fa-bars');
                document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('panel-active'));
            }
        });

        // Accordion Sub-menu Logic (Mobile Only)
        const setupMobilePanels = () => {
            document.querySelectorAll('.nav-item').forEach(item => {
                const link = item.querySelector('.nav-link');
                const dropdown = item.querySelector('.dropdown-menu');

                if (link && dropdown) {
                    link.addEventListener('click', (e) => {
                        if (window.innerWidth <= 992) {
                            e.preventDefault();
                            
                            // Close other open accordion panels
                            document.querySelectorAll('.nav-item').forEach(otherItem => {
                                if (otherItem !== item) {
                                    otherItem.classList.remove('panel-active');
                                }
                            });
                            
                            item.classList.toggle('panel-active');
                        }
                    });
                }
            });
        };

        // Initialize mobile panels
        setupMobilePanels();

        // Close menu on click anywhere else
        document.addEventListener('click', (e) => {
            if (navLinks.classList.contains('active') && !navLinks.contains(e.target) && !navToggle.contains(e.target)) {
                navLinks.classList.remove('active');
                const icon = navToggle.querySelector('i');
                icon.classList.replace('fa-times', 'fa-bars');
                document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('panel-active'));
            }
        });

        // Close menu on link click
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', (e) => {
                // Skip if this link is meant to toggle an accordion sub-menu
                if (link.nextElementSibling && link.nextElementSibling.classList.contains('dropdown-menu')) {
                    return; 
                }

                if (window.innerWidth <= 992) {
                    navLinks.classList.remove('active');
                    const icon = navToggle.querySelector('i');
                    if (icon) icon.classList.replace('fa-times', 'fa-bars');
                    document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('panel-active'));
                }
            });
        });
    }
});

// --- Dynamic Pricing Engine ---
const pricingData = {
    coworking: {
        title: "Coworking Pricing",
        locations: {
            "MORNINGSIDE, SANDTON": [{ title: "Monthly Membership", price: "R1 200.00", vat: "Excluding VAT", sub: "/ month", features: ["2 hours FREE meeting room access","Access to kitchen facilities","Mail & package handling","Professional business address","Dedicated phone number","Free uncapped wifi"] }],
            "CHADWICK, WYNBERG": [{ title: "Monthly Membership", price: "R1 100.00", vat: "Excluding VAT", sub: "/ month", features: ["2 hours FREE meeting room access","Access to kitchen facilities","Mail & package handling","Professional business address","Dedicated phone number","Free uncapped wifi"] }],
            "VILLAGE, JHB": [{ title: "Monthly Membership", price: "R950.00", vat: "Excluding VAT", sub: "/ month", features: ["2 hours FREE meeting room access","Access to kitchen facilities","Mail & package handling","Professional business address","Dedicated phone number","Free uncapped wifi"] }]
        }
    },
    "virtual-office": {
        title: "Virtual Office Pricing",
        locations: {
            "MORNINGSIDE, SANDTON": [{ title: "Monthly Virtual Office", price: "R599.00", vat: "Excluding VAT", sub: "/ month", features: ["Access to meeting rooms at reduced cost","Mail & package handling","Professional business address","Dedicated phone number"] }],
            "CHADWICK, WYNBERG": [{ title: "Monthly Virtual Office", price: "R499.00", vat: "Excluding VAT", sub: "/ month", features: ["Access to meeting rooms at reduced cost","Mail & package handling","Professional business address","Dedicated phone number"] }],
            "VILLAGE, JHB": [{ title: "Monthly Virtual Office", price: "R450.00", vat: "Excluding VAT", sub: "/ month", features: ["Access to meeting rooms at reduced cost","Mail & package handling","Professional business address","Dedicated phone number"] }]
        }
    },
    "private-offices": {
        title: "Private Office Pricing",
        locations: {
            "MORNINGSIDE, SANDTON": [
                { title: "Half Day", price: "R380.00", vat: "Excluding VAT", desc: "Perfect for quick meetings or focused sessions.", highlight: false },
                { title: "Full Day", price: "R520.00", vat: "Excluding VAT", desc: "Total access for a full day of productivity.", highlight: true },
                { title: "Monthly Suite", price: "R3 800.00", vat: "Excluding VAT", desc: "Starting monthly rate for tailored suites.", highlight: false }
            ],
            "CHADWICK, WYNBERG": [
                { title: "Half Day", price: "R330.00", vat: "Excluding VAT", desc: "Perfect for quick meetings or focused sessions.", highlight: false },
                { title: "Full Day", price: "R450.00", vat: "Excluding VAT", desc: "Total access for a full day of productivity.", highlight: true },
                { title: "5-Day Week", price: "R1 500.00", vat: "Excluding VAT", desc: "Reduced rate for weekly bookings.", highlight: false }
            ],
            "VILLAGE, JHB": [
                { title: "Half Day", price: "R299.00", vat: "Excluding VAT", desc: "Perfect for quick meetings or focused sessions.", highlight: false },
                { title: "Full Day", price: "R420.00", vat: "Excluding VAT", desc: "Total access for a full day of productivity.", highlight: true },
                { title: "5-Day Week", price: "R1 380.00", vat: "Excluding VAT", desc: "Reduced rate for weekly bookings.", highlight: false }
            ]
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    const locationBtns = document.querySelectorAll('.location-btn');
    if(locationBtns.length > 0) {
        const container = document.getElementById('dynamic-pricing-container');
        const grid = document.getElementById('dynamic-pricing-grid');
        const defaultState = document.querySelector('.pricing-default-state');
        const service = document.querySelector('.location-buttons').getAttribute('data-service');
        const pricingTitle = document.getElementById('pricing-title');

        locationBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const loc = e.target.getAttribute('data-location');
                
                // Active state
                locationBtns.forEach(b => {
                    b.classList.remove('btn-primary');
                    b.classList.add('btn-outline');
                });
                e.target.classList.remove('btn-outline');
                e.target.classList.add('btn-primary');
                
                // Animate Out
                container.style.opacity = '0';
                
                setTimeout(() => {
                    defaultState.style.display = 'none';
                    grid.style.display = 'grid';
                    
                    // Update Title
                    pricingTitle.innerHTML = `${pricingData[service].title} <span style="color: var(--primary-blue)">- ${loc}</span>`;
                    
                    // Rebuild Grid
                    const plans = pricingData[service].locations[loc];
                    
                    if(service === 'private-offices') {
                        grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
                        grid.style.maxWidth = '1200px';
                        grid.style.margin = '4rem auto 0';
                    } else {
                        grid.style.gridTemplateColumns = '1fr';
                        grid.style.maxWidth = '600px';
                        grid.style.margin = '4rem auto 0';
                    }
                    
                    grid.innerHTML = plans.map(plan => `
                        <div class="pricing-card" style="${plan.highlight ? 'border-color: var(--primary-blue); transform: scale(1.05); box-shadow: var(--shadow);' : ''}">
                            <h3 class="service-title">${plan.title}</h3>
                            <div class="pricing-label">starting from</div>
                            <div class="pricing-price">${plan.price}${plan.sub ? `<span> ${plan.sub}</span>` : ''}</div>
                            <div class="pricing-vat">${plan.vat}</div>
                            ${plan.desc ? `<p class="service-desc">${plan.desc}</p>` : ''}
                            ${plan.features ? `
                                <div style="text-align: left; margin-bottom: 3rem;">
                                    <ul style="list-style: none; padding: 0;">
                                        ${plan.features.map(f => `
                                        <li style="margin-bottom: 1rem; display: flex; align-items: flex-start; gap: 1rem;">
                                            <i class="fas fa-check-circle" style="color: var(--primary-blue); margin-top: 0.3rem;"></i>
                                            ${f}
                                        </li>
                                        `).join('')}
                                    </ul>
                                </div>
                            ` : ''}
                            <div style="margin-top: auto;">
                                <a href="contact.html?location=${encodeURIComponent(loc.split(',')[0])}" class="btn ${plan.highlight ? 'btn-primary' : 'btn-outline'}">${plan.features ? 'Get Started' : 'Book Now'}</a>
                            </div>
                        </div>
                    `).join('');
                    
                    if(window.innerWidth <= 768) {
                        grid.style.gridTemplateColumns = '1fr';
                        grid.querySelectorAll('.pricing-card').forEach(c => c.style.transform = 'none');
                    }
                    
                    // Animate In
                    container.style.opacity = '1';
                }, 400);
            });
        });
    }
});
