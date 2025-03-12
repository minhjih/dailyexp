// DOM이 완전히 로드된 후 실행
document.addEventListener('DOMContentLoaded', function() {
    // 네비게이션 스크롤 효과 - 헤더 고정 제거
    const header = document.querySelector('.header');
    const scrollWatcher = () => {
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    };
    // 스크롤 이벤트 리스너 제거 (헤더 고정 기능 비활성화)
    // window.addEventListener('scroll', scrollWatcher);

    // 히어로 섹션의 부유 요소 스크롤 시 숨기기
    const heroSection = document.querySelector('.hero');
    const floatingElements = document.querySelector('.floating-elements');
    const appScreenshot = document.querySelector('.app-screenshot');
    
    window.addEventListener('scroll', function() {
        const heroBottom = heroSection.getBoundingClientRect().bottom;
        const windowHeight = window.innerHeight;
        
        // 히어로 섹션이 화면에서 벗어나기 시작하면 부유 요소와 앱 스크린샷 숨기기
        if (heroBottom < windowHeight) {
            const opacity = Math.max(0, heroBottom / windowHeight);
            if (floatingElements) floatingElements.style.opacity = opacity;
            if (appScreenshot) appScreenshot.style.opacity = opacity;
        } else {
            if (floatingElements) floatingElements.style.opacity = 1;
            if (appScreenshot) appScreenshot.style.opacity = 1;
        }
    });

    // 모바일 메뉴 토글
    const mobileMenuBtn = document.createElement('div');
    mobileMenuBtn.className = 'mobile-menu-btn';
    mobileMenuBtn.innerHTML = '<span></span><span></span><span></span>';
    document.querySelector('.navbar').appendChild(mobileMenuBtn);

    const navLinks = document.querySelector('.nav-links');
    mobileMenuBtn.addEventListener('click', function() {
        this.classList.toggle('active');
        navLinks.classList.toggle('active');
    });

    // 스크롤 애니메이션
    const animateOnScroll = () => {
        const elements = document.querySelectorAll('.animate-on-scroll');
        
        elements.forEach(element => {
            const elementPosition = element.getBoundingClientRect().top;
            const windowHeight = window.innerHeight;
            
            if (elementPosition < windowHeight - 100) {
                element.classList.add('animated');
            }
        });
    };
    
    // 초기 애니메이션 실행
    animateOnScroll();
    window.addEventListener('scroll', animateOnScroll);

    // 애니메이션 클래스 추가
    const addAnimationClasses = () => {
        document.querySelectorAll('.feature-card').forEach((card, index) => {
            card.classList.add('animate-on-scroll');
            card.style.animationDelay = `${index * 0.1}s`;
        });

        document.querySelectorAll('.section-header').forEach(header => {
            header.classList.add('animate-on-scroll');
        });

        document.querySelectorAll('.about-content, .about-image').forEach(element => {
            element.classList.add('animate-on-scroll');
        });

        // 비즈니스 모델 섹션 애니메이션
        document.querySelectorAll('.business-card').forEach((card, index) => {
            card.classList.add('animate-on-scroll');
            card.style.animationDelay = `${index * 0.1}s`;
        });

        document.querySelectorAll('.process-step').forEach((step, index) => {
            step.classList.add('animate-on-scroll');
            step.style.animationDelay = `${index * 0.2}s`;
        });

        document.querySelectorAll('.business-process').forEach(process => {
            process.classList.add('animate-on-scroll');
        });
    };
    
    addAnimationClasses();

    // 카운터 애니메이션
    const animateCounter = (element, target) => {
        let current = 0;
        const increment = target / 100;
        const timer = setInterval(() => {
            current += increment;
            element.textContent = Math.floor(current);
            if (current >= target) {
                element.textContent = target;
                clearInterval(timer);
            }
        }, 20);
    };

    // 통계 숫자 애니메이션
    const animateStats = () => {
        const statElements = document.querySelectorAll('.stat-number');
        statElements.forEach(element => {
            // 목표 사용자 수는 애니메이션 적용하지 않음
            if (element.nextElementSibling && element.nextElementSibling.textContent.trim() === "목표 사용자") {
                return;
            }
            
            const target = parseInt(element.getAttribute('data-target'));
            if (!isNaN(target)) {
                animateCounter(element, target);
            }
        });
    };

    // 통계 섹션이 보이면 애니메이션 시작
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateStats();
                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    const statsContainer = document.querySelector('.stats-container');
    if (statsContainer) {
        statsObserver.observe(statsContainer);
    }

    // 폼 제출 처리
    const contactForm = document.querySelector('.contact-form');
    if (contactForm) {
        // FormSubmit 서비스를 사용하므로 자바스크립트 처리는 필요 없음
        // 첫 번째 폼 제출 시 FormSubmit에서 확인 이메일을 보내므로 안내 메시지 추가
        contactForm.addEventListener('submit', function(e) {
            // 폼 제출은 그대로 진행됨 (e.preventDefault() 호출 안 함)
            console.log('폼이 제출되었습니다. FormSubmit 서비스로 처리됩니다.');
            
            // 첫 번째 제출 시 FormSubmit 안내 메시지 표시
            const formSubmitMessage = document.createElement('div');
            formSubmitMessage.className = 'success-message';
            formSubmitMessage.style.position = 'fixed';
            formSubmitMessage.style.bottom = '20px';
            formSubmitMessage.style.right = '20px';
            formSubmitMessage.style.padding = '15px';
            formSubmitMessage.style.zIndex = '9999';
            formSubmitMessage.textContent = '첫 번째 제출 시 FormSubmit에서 확인 이메일을 보낼 수 있습니다. 이메일을 확인해주세요.';
            
            document.body.appendChild(formSubmitMessage);
            
            // 5초 후 메시지 제거
            setTimeout(() => {
                formSubmitMessage.style.opacity = '0';
                setTimeout(() => {
                    document.body.removeChild(formSubmitMessage);
                }, 500);
            }, 5000);
        });
    }

    // 스크롤 시 요소 페이드인 효과
    const fadeInElements = document.querySelectorAll('.fade-in');
    
    const fadeInObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                fadeInObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    
    fadeInElements.forEach(element => {
        fadeInObserver.observe(element);
    });

    // 부드러운 스크롤 내비게이션
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 100,
                    behavior: 'smooth'
                });
                
                // 모바일 메뉴가 열려있으면 닫기
                if (navLinks.classList.contains('active')) {
                    navLinks.classList.remove('active');
                    mobileMenuBtn.classList.remove('active');
                }
            }
        });
    });

    // 타이핑 효과
    const typingElement = document.querySelector('.typing-effect');
    if (typingElement) {
        const text = typingElement.textContent;
        typingElement.textContent = '';
        
        let i = 0;
        const typeWriter = () => {
            if (i < text.length) {
                typingElement.textContent += text.charAt(i);
                i++;
                setTimeout(typeWriter, 100);
            }
        };
        
        typeWriter();
    }

    // 이미지 지연 로딩
    const lazyImages = document.querySelectorAll('img[data-src]');
    
    const lazyImageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.getAttribute('data-src');
                img.removeAttribute('data-src');
                lazyImageObserver.unobserve(img);
            }
        });
    });
    
    lazyImages.forEach(image => {
        lazyImageObserver.observe(image);
    });

    // 다크 모드 토글
    const darkModeToggle = document.createElement('button');
    darkModeToggle.className = 'dark-mode-toggle';
    darkModeToggle.innerHTML = '<i class="fas fa-moon"></i>';
    document.body.appendChild(darkModeToggle);
    
    darkModeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        
        if (document.body.classList.contains('dark-mode')) {
            darkModeToggle.innerHTML = '<i class="fas fa-sun"></i>';
            localStorage.setItem('darkMode', 'enabled');
            console.log('다크 모드 활성화: 푸터 스타일 확인');
        } else {
            darkModeToggle.innerHTML = '<i class="fas fa-moon"></i>';
            localStorage.setItem('darkMode', 'disabled');
            console.log('다크 모드 비활성화: 푸터 스타일 확인');
        }
    });
    
    // 저장된 다크 모드 설정 불러오기
    if (localStorage.getItem('darkMode') === 'enabled') {
        document.body.classList.add('dark-mode');
        darkModeToggle.innerHTML = '<i class="fas fa-sun"></i>';
    }
}); 