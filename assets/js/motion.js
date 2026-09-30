/* =========================================================
   SODIQ OLUWATIMILEYIN — MOTION LAYER
   GSAP (ScrollTrigger, SplitText) + Lenis smooth scroll
========================================================= */

(function () {

    "use strict";

    window.__motionReady = true;

    const root = document.documentElement;
    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const finePointer = window.matchMedia("(hover: hover) and (pointer: fine)").matches;
    const hasGSAP = typeof window.gsap !== "undefined" && typeof window.ScrollTrigger !== "undefined";
    const hasSplit = hasGSAP && typeof window.SplitText !== "undefined";

    const hero = document.querySelector(".hero");
    const legend = document.querySelector(".hero-legend");
    const nav = document.querySelector(".site-nav");

    function clamp(value, min, max) {
        return Math.min(max, Math.max(min, value));
    }

    function easeInOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }

    function navHeight() {
        return nav ? nav.offsetHeight : 0;
    }

    function setLegend(progress) {
        if (legend) {
            legend.setAttribute("data-state", progress > 0.62 ? "signal" : "raw");
        }
    }


    /* =====================================================
       SIGNAL FIELD — raw transactions assembling into a chart
    ====================================================== */

    function createSignalField(canvas, host) {

        const ctx = canvas.getContext("2d");

        if (!ctx) {
            return null;
        }

        const BAR_VALUES = [0.32, 0.4, 0.36, 0.48, 0.45, 0.56, 0.52, 0.64, 0.61, 0.74, 0.83, 1];
        const WINDOW = 0.35;

        const state = {
            width: 0,
            height: 0,
            progress: 0,
            particles: [],
            hiStart: 0,
            size: 4.6,
            trend: [],
            trendLengths: [0],
            trendTotal: 0,
            pointer: null,
            running: false,
            visible: true,
            frameId: 0,
            autoId: 0,
            autoDone: false,
            staticMode: false
        };

        function build() {

            const rect = host.getBoundingClientRect();
            const width = rect.width;
            const height = rect.height;
            const dpr = Math.min(window.devicePixelRatio || 1, 2);

            state.width = width;
            state.height = height;

            canvas.width = Math.round(width * dpr);
            canvas.height = Math.round(height * dpr);
            ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

            const compact = width < 700;
            const values = compact ? BAR_VALUES.slice(4) : BAR_VALUES;
            const pitch = compact ? 6 : 8;
            const left = width * (compact ? 0.07 : 0.1);
            const right = width * (compact ? 0.93 : 0.9);
            const bottom = height - (compact ? 64 : 76);
            const maxBar = height * (compact ? 0.22 : 0.3);
            const slot = (right - left) / values.length;
            const cols = Math.max(2, Math.floor((slot * 0.6) / pitch));
            const barWidth = cols * pitch;

            const regular = [];
            const highlight = [];
            const trend = [];

            values.forEach(function (value, bar) {

                const rows = Math.max(2, Math.round((maxBar * value) / pitch));
                const x0 = left + slot * bar + (slot - barWidth) / 2;
                const isLast = bar === values.length - 1;

                trend.push({
                    x: x0 + barWidth / 2,
                    y: bottom - rows * pitch - 18
                });

                for (let row = 0; row < rows; row++) {
                    for (let col = 0; col < cols; col++) {

                        const particle = {
                            tx: x0 + col * pitch + pitch / 2,
                            ty: bottom - row * pitch - pitch / 2,
                            sx: Math.random() * width,
                            sy: Math.random() * height,
                            amp: 4 + Math.random() * 10,
                            speed: 0.25 + Math.random() * 0.55,
                            phase: Math.random() * Math.PI * 2,
                            a0: 0.18 + Math.random() * 0.4,
                            a1: isLast ? 0.95 : 0.34 + (row / rows) * 0.36,
                            delay: (bar / values.length) * 0.4 + (row / rows) * 0.18 + Math.random() * 0.07
                        };

                        (isLast ? highlight : regular).push(particle);
                    }
                }
            });

            state.hiStart = regular.length;
            state.particles = regular.concat(highlight);
            state.size = compact ? 3.6 : 4.6;
            state.trend = trend;

            const lengths = [0];
            let total = 0;

            for (let i = 1; i < trend.length; i++) {
                total += Math.hypot(trend[i].x - trend[i - 1].x, trend[i].y - trend[i - 1].y);
                lengths.push(total);
            }

            state.trendLengths = lengths;
            state.trendTotal = total;
        }

        function drawTrend(time, progress) {

            const lineProgress = clamp((progress - 0.7) / 0.3, 0, 1);
            const points = state.trend;

            if (lineProgress <= 0 || points.length < 2) {
                return;
            }

            const target = state.trendTotal * easeInOutCubic(lineProgress);
            const lengths = state.trendLengths;

            let endX = points[0].x;
            let endY = points[0].y;

            ctx.save();
            ctx.strokeStyle = "rgba(255, 255, 255, 0.9)";
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.moveTo(points[0].x, points[0].y);

            for (let i = 1; i < points.length; i++) {

                if (lengths[i] <= target) {
                    ctx.lineTo(points[i].x, points[i].y);
                    endX = points[i].x;
                    endY = points[i].y;
                } else {
                    const segment = lengths[i] - lengths[i - 1];
                    const f = segment ? (target - lengths[i - 1]) / segment : 0;
                    endX = points[i - 1].x + (points[i].x - points[i - 1].x) * f;
                    endY = points[i - 1].y + (points[i].y - points[i - 1].y) * f;
                    ctx.lineTo(endX, endY);
                    break;
                }
            }

            ctx.stroke();

            ctx.fillStyle = "#ffffff";
            ctx.beginPath();
            ctx.arc(endX, endY, 3.5, 0, Math.PI * 2);
            ctx.fill();

            if (lineProgress >= 1) {
                const pulse = (Math.sin(time * 2.4) + 1) / 2;
                ctx.globalAlpha = 0.35 * (1 - pulse);
                ctx.beginPath();
                ctx.arc(endX, endY, 6 + pulse * 10, 0, Math.PI * 2);
                ctx.fill();
            }

            ctx.restore();
        }

        function draw(now) {

            const time = now / 1000;
            const progress = state.progress;
            const particles = state.particles;
            const size = state.size;
            const half = size / 2;
            const pointer = state.pointer;

            ctx.clearRect(0, 0, state.width, state.height);
            ctx.fillStyle = "#bca6ff";

            for (let i = 0; i < particles.length; i++) {

                if (i === state.hiStart) {
                    ctx.fillStyle = "#ffffff";
                }

                const p = particles[i];
                const e = easeInOutCubic(clamp((progress - p.delay) / WINDOW, 0, 1));

                let sx = p.sx + Math.sin(time * p.speed + p.phase) * p.amp;
                let sy = p.sy + Math.cos(time * p.speed * 0.8 + p.phase) * p.amp;

                if (pointer && e < 1) {
                    const dx = sx - pointer.x;
                    const dy = sy - pointer.y;
                    const distanceSq = dx * dx + dy * dy;

                    if (distanceSq < 14400) {
                        const distance = Math.sqrt(distanceSq) || 1;
                        const force = (1 - distance / 120) * 26 * (1 - e);
                        sx += (dx / distance) * force;
                        sy += (dy / distance) * force;
                    }
                }

                ctx.globalAlpha = p.a0 + (p.a1 - p.a0) * e;
                ctx.fillRect(sx + (p.tx - sx) * e - half, sy + (p.ty - sy) * e - half, size, size);
            }

            ctx.globalAlpha = 1;
            drawTrend(time, progress);
        }

        function loop(now) {
            if (!state.running) {
                return;
            }
            draw(now);
            state.frameId = requestAnimationFrame(loop);
        }

        function start() {
            if (state.running || state.staticMode || !state.visible || document.hidden) {
                return;
            }
            state.running = true;
            state.frameId = requestAnimationFrame(loop);
        }

        function stop() {
            state.running = false;
            cancelAnimationFrame(state.frameId);
        }

        build();

        if ("IntersectionObserver" in window) {
            new IntersectionObserver(function (entries) {
                state.visible = entries[0].isIntersecting;
                if (state.visible) {
                    start();
                } else {
                    stop();
                }
            }).observe(host);
        } else {
            start();
        }

        document.addEventListener("visibilitychange", function () {
            if (document.hidden) {
                stop();
            } else {
                start();
            }
        });

        if (finePointer) {
            host.addEventListener("pointermove", function (event) {
                const rect = canvas.getBoundingClientRect();
                state.pointer = { x: event.clientX - rect.left, y: event.clientY - rect.top };
            });
            host.addEventListener("pointerleave", function () {
                state.pointer = null;
            });
        }

        let resizeTimer = 0;

        window.addEventListener("resize", function () {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function () {
                const rect = host.getBoundingClientRect();
                if (Math.abs(rect.width - state.width) < 1 && Math.abs(rect.height - state.height) < 140) {
                    return;
                }
                build();
                if (state.staticMode) {
                    draw(0);
                }
            }, 180);
        });

        function setProgress(value) {
            state.progress = clamp(value, 0, 1);
        }

        function cancelAuto() {
            cancelAnimationFrame(state.autoId);
        }

        function autoPlay(delay, duration, onUpdate) {

            if (state.autoDone) {
                if (onUpdate) {
                    onUpdate(state.progress);
                }
                return;
            }

            cancelAuto();

            const from = state.progress;
            const startAt = performance.now() + delay * 1000;

            function tick(now) {
                const t = clamp((now - startAt) / (duration * 1000), 0, 1);
                state.progress = from + (1 - from) * t;
                if (onUpdate) {
                    onUpdate(state.progress);
                }
                if (t < 1) {
                    state.autoId = requestAnimationFrame(tick);
                } else {
                    state.autoDone = true;
                }
            }

            state.autoId = requestAnimationFrame(tick);
        }

        function renderStatic(value) {
            state.staticMode = true;
            stop();
            state.progress = clamp(value, 0, 1);
            draw(0);
        }

        return {
            setProgress: setProgress,
            autoPlay: autoPlay,
            cancelAuto: cancelAuto,
            renderStatic: renderStatic
        };
    }

    const heroCanvas = document.querySelector(".hero-canvas");
    const field = heroCanvas && hero ? createSignalField(heroCanvas, hero) : null;

    if (field) {
        root.classList.add("has-canvas");
    }


    /* =====================================================
       FALLBACKS — no GSAP, or reduced motion
    ====================================================== */

    if (!hasGSAP) {

        root.classList.remove("js-motion");

        if (field) {
            if (reduceMotion) {
                field.renderStatic(1);
                setLegend(1);
            } else {
                setLegend(0);
                field.autoPlay(0.8, 2.8, setLegend);
            }
        }

        return;
    }

    if (reduceMotion) {

        if (field) {
            field.renderStatic(1);
            setLegend(1);
        }

        return;
    }

    gsap.registerPlugin(ScrollTrigger);

    if (hasSplit) {
        gsap.registerPlugin(SplitText);
    }

    ScrollTrigger.config({ ignoreMobileResize: true });

    setLegend(0);


    /* =====================================================
       SMOOTH SCROLL
    ====================================================== */

    let lenis = null;

    if (typeof window.Lenis !== "undefined") {

        lenis = new Lenis({
            lerp: 0.1,
            smoothWheel: true
        });

        lenis.on("scroll", ScrollTrigger.update);

        gsap.ticker.add(function (time) {
            lenis.raf(time * 1000);
        });

        gsap.ticker.lagSmoothing(0);

    } else {

        root.style.scrollBehavior = "auto";
    }

    function scrollToTarget(target, immediate) {

        const offset = -navHeight();

        if (lenis) {
            lenis.scrollTo(target, { offset: offset, duration: 1.4, immediate: !!immediate, force: true });
            return;
        }

        const top = target.getBoundingClientRect().top + window.scrollY + offset;
        window.scrollTo({ top: top, behavior: immediate ? "auto" : "smooth" });
    }

    function findTarget(hash) {
        if (!hash || hash.length < 2) {
            return null;
        }
        try {
            return document.querySelector(hash);
        } catch (error) {
            return null;
        }
    }

    document.addEventListener("click", function (event) {

        const link = event.target.closest('a[href^="#"]');

        if (!link) {
            return;
        }

        const hash = link.getAttribute("href");
        const target = findTarget(hash);

        if (!target) {
            return;
        }

        event.preventDefault();
        scrollToTarget(target, false);

        if (window.history && window.history.replaceState) {
            window.history.replaceState(null, "", hash);
        }

        if (!target.hasAttribute("tabindex")) {
            target.setAttribute("tabindex", "-1");
        }

        target.focus({ preventScroll: true });
    });


    /* =====================================================
       PINNED SCENES
    ====================================================== */

    const mm = gsap.matchMedia();

    if (hero && field) {

        mm.add({
            pinned: "(min-width: 900px) and (hover: hover) and (pointer: fine)",
            free: "(max-width: 899px), (hover: none), (pointer: coarse)"
        }, function (context) {

            if (context.conditions.pinned) {

                field.cancelAuto();

                const heroTimeline = gsap.timeline({
                    scrollTrigger: {
                        trigger: hero,
                        start: "top top",
                        end: "+=90%",
                        pin: true,
                        scrub: 0.6,
                        refreshPriority: 3
                    },
                    onUpdate: function () {
                        field.setProgress(heroTimeline.progress());
                        setLegend(heroTimeline.progress());
                    }
                });

                heroTimeline.to(".hero-inner", { yPercent: -8, opacity: 0.38, ease: "none" }, 0);

            } else {

                field.autoPlay(1.4, 2.8, setLegend);
            }
        });
    }

    const method = document.querySelector(".method");

    if (method) {

        const steps = gsap.utils.toArray(".method-step");
        const meterFill = method.querySelector(".method-meter-fill");

        mm.add("(min-width: 1024px) and (min-height: 700px)", function () {

            method.classList.add("is-pinned");

            let current = -1;

            function activate(index) {
                if (index === current) {
                    return;
                }
                current = index;
                steps.forEach(function (step, i) {
                    step.classList.toggle("is-active", i === index);
                });
            }

            activate(0);

            ScrollTrigger.create({
                trigger: method,
                start: function () { return "top top+=" + navHeight(); },
                end: function () { return "+=" + Math.round(window.innerHeight * 1.8); },
                pin: true,
                refreshPriority: 2,
                onUpdate: function (self) {
                    activate(Math.min(steps.length - 1, Math.floor(self.progress * steps.length)));
                    if (meterFill) {
                        gsap.set(meterFill, { scaleX: self.progress });
                    }
                }
            });

            return function () {
                method.classList.remove("is-pinned");
                steps.forEach(function (step) {
                    step.classList.remove("is-active");
                });
            };
        });

        mm.add("(max-width: 1023px), (max-height: 699px)", function () {

            gsap.from(steps, {
                opacity: 0,
                y: 40,
                duration: 1,
                ease: "expo.out",
                stagger: 0.12,
                scrollTrigger: {
                    trigger: method.querySelector(".method-steps"),
                    start: "top 82%",
                    once: true
                }
            });
        });
    }

    const work = document.querySelector(".work");

    if (work) {

        const track = work.querySelector(".work-track");
        const cards = gsap.utils.toArray(".work-card");
        const progressItems = gsap.utils.toArray(".work-progress li");
        const progressFill = work.querySelector(".work-progress-fill");

        mm.add("(min-width: 1024px) and (min-height: 800px)", function () {

            work.classList.add("is-horizontal");

            function distance() {
                return Math.max(0, track.scrollWidth - document.documentElement.clientWidth);
            }

            const slide = gsap.to(track, {
                x: function () { return -distance(); },
                ease: "none",
                scrollTrigger: {
                    trigger: work,
                    start: function () { return "top top+=" + navHeight(); },
                    end: function () { return "+=" + distance(); },
                    pin: true,
                    scrub: 0.8,
                    invalidateOnRefresh: true,
                    refreshPriority: 1,
                    onUpdate: function (self) {
                        const index = Math.round(self.progress * (progressItems.length - 1));
                        progressItems.forEach(function (item, i) {
                            item.classList.toggle("is-active", i === index);
                        });
                        if (progressFill) {
                            gsap.set(progressFill, { scaleX: self.progress });
                        }
                    }
                }
            });

            cards.forEach(function (card) {

                const image = card.querySelector(".work-media img");

                if (!image) {
                    return;
                }

                gsap.fromTo(image,
                    { xPercent: -6, scale: 1.14 },
                    {
                        xPercent: 6,
                        scale: 1.14,
                        ease: "none",
                        scrollTrigger: {
                            trigger: card,
                            containerAnimation: slide,
                            start: "left right",
                            end: "right left",
                            scrub: true
                        }
                    }
                );
            });

            gsap.from(cards, {
                opacity: 0,
                y: 60,
                duration: 1.1,
                ease: "expo.out",
                stagger: 0.1,
                scrollTrigger: {
                    trigger: work,
                    start: "top 70%",
                    once: true
                }
            });

            return function () {
                work.classList.remove("is-horizontal");
            };
        });

        mm.add("(max-width: 1023px), (max-height: 799px)", function () {

            gsap.set(cards, { opacity: 0, y: 50 });

            ScrollTrigger.batch(cards, {
                start: "top 88%",
                once: true,
                onEnter: function (batch) {
                    gsap.to(batch, { opacity: 1, y: 0, duration: 1, ease: "expo.out", stagger: 0.1 });
                }
            });
        });
    }


    /* =====================================================
       HEADINGS — masked line reveals
    ====================================================== */

    function maskLines(lines) {
        lines.forEach(function (line) {
            const mask = document.createElement("div");
            mask.className = "line-mask";
            line.parentNode.insertBefore(mask, line);
            mask.appendChild(line);
        });
    }

    function revealHeading(element) {

        if (!hasSplit) {
            gsap.from(element, {
                opacity: 0,
                y: 30,
                duration: 1,
                ease: "expo.out",
                scrollTrigger: { trigger: element, start: "top 88%", once: true }
            });
            return;
        }

        new SplitText(element, {
            type: "lines",
            linesClass: "split-line",
            autoSplit: true,
            onSplit: function (self) {

                maskLines(self.lines);

                if (element.dataset.revealed === "true") {
                    return;
                }

                return gsap.from(self.lines, {
                    yPercent: 110,
                    duration: 1.1,
                    ease: "expo.out",
                    stagger: 0.1,
                    scrollTrigger: {
                        trigger: element,
                        start: "top 88%",
                        once: true,
                        onEnter: function () {
                            element.dataset.revealed = "true";
                        }
                    }
                });
            }
        });
    }

    document.querySelectorAll("[data-split]").forEach(revealHeading);


    /* =====================================================
       ABOUT — words light up as you read
    ====================================================== */

    const lead = document.querySelector("[data-scrub-words]");

    if (lead && hasSplit) {

        new SplitText(lead, {
            type: "words",
            wordsClass: "scrub-word",
            autoSplit: true,
            onSplit: function (self) {
                return gsap.fromTo(self.words,
                    { opacity: 0.16 },
                    {
                        opacity: 1,
                        ease: "none",
                        stagger: 0.05,
                        scrollTrigger: {
                            trigger: lead,
                            start: "top 82%",
                            end: "bottom 50%",
                            scrub: true
                        }
                    }
                );
            }
        });
    }

    const photoFrame = document.querySelector(".about-photo-frame");

    if (photoFrame) {
        gsap.fromTo(photoFrame,
            { y: 50, rotate: -4 },
            {
                y: -30,
                rotate: 1,
                ease: "none",
                scrollTrigger: {
                    trigger: ".about",
                    start: "top bottom",
                    end: "bottom top",
                    scrub: true
                }
            }
        );
    }


    /* =====================================================
       GENERIC REVEALS
    ====================================================== */

    const revealElements = gsap.utils.toArray("[data-reveal]");

    gsap.set(revealElements, { opacity: 0, y: 36 });

    ScrollTrigger.batch(revealElements, {
        start: "top 88%",
        once: true,
        onEnter: function (batch) {
            gsap.to(batch, {
                opacity: 1,
                y: 0,
                duration: 1,
                ease: "expo.out",
                stagger: 0.09,
                overwrite: true
            });
        }
    });


    /* =====================================================
       OTHER PROJECTS — image wipes and counting stats
    ====================================================== */

    function prepareCount(element) {

        const raw = element.textContent.trim();
        const match = raw.match(/^([^\d]*)(\d[\d,]*(?:\.\d+)?)(.*)$/);

        if (!match) {
            return;
        }

        element.dataset.countFinal = raw;
        element.dataset.countPrefix = match[1];
        element.dataset.countSuffix = match[3];
        element.dataset.countTarget = match[2].replace(/,/g, "");
        element.dataset.countDecimals = String((match[2].split(".")[1] || "").length);
        element.dataset.countGroup = match[2].indexOf(",") !== -1 ? "1" : "0";
        element.textContent = formatCount(element, 0);
    }

    function formatCount(element, value) {

        const decimals = parseInt(element.dataset.countDecimals, 10) || 0;

        return element.dataset.countPrefix +
            value.toLocaleString("en-US", {
                minimumFractionDigits: decimals,
                maximumFractionDigits: decimals,
                useGrouping: element.dataset.countGroup === "1"
            }) +
            element.dataset.countSuffix;
    }

    function countUp(element) {

        if (!element.dataset.countTarget) {
            return;
        }

        const counter = { value: 0 };

        gsap.to(counter, {
            value: parseFloat(element.dataset.countTarget),
            duration: 1.6,
            ease: "power3.out",
            onUpdate: function () {
                element.textContent = formatCount(element, counter.value);
            },
            onComplete: function () {
                element.textContent = element.dataset.countFinal;
            }
        });
    }

    gsap.utils.toArray(".case").forEach(function (card, index) {

        const media = card.querySelector(".case-media");
        const image = card.querySelector(".case-media img");
        const body = card.querySelectorAll(".case-body > *");
        const stats = card.querySelectorAll(".stats strong");
        const fromLeft = index % 2 === 0;

        stats.forEach(prepareCount);

        const timeline = gsap.timeline({
            scrollTrigger: {
                trigger: card,
                start: "top 78%",
                once: true
            }
        });

        if (media) {
            timeline.fromTo(media,
                { clipPath: fromLeft ? "inset(0% 100% 0% 0%)" : "inset(0% 0% 0% 100%)" },
                { clipPath: "inset(0% 0% 0% 0%)", duration: 1.3, ease: "expo.inOut" },
                0
            );
        }

        if (image) {
            timeline.fromTo(image, { scale: 1.3 }, { scale: 1, duration: 1.8, ease: "expo.out" }, 0.1);
        }

        timeline
            .from(body, { opacity: 0, y: 26, duration: 0.9, ease: "expo.out", stagger: 0.07 }, 0.35)
            .add(function () {
                stats.forEach(countUp);
            }, 0.7);
    });


    /* =====================================================
       SKILLS
    ====================================================== */

    const skillCards = gsap.utils.toArray(".skill-card");

    gsap.set(skillCards, { opacity: 0, y: 44 });

    ScrollTrigger.batch(skillCards, {
        start: "top 88%",
        once: true,
        onEnter: function (batch) {

            gsap.to(batch, { opacity: 1, y: 0, duration: 1, ease: "expo.out", stagger: 0.1 });

            batch.forEach(function (card, i) {
                gsap.from(card.querySelectorAll(".skill-list li"), {
                    opacity: 0,
                    x: -12,
                    duration: 0.6,
                    ease: "power2.out",
                    stagger: 0.04,
                    delay: 0.25 + i * 0.1
                });
            });
        }
    });


    /* =====================================================
       MARQUEE — reacts to scroll speed
    ====================================================== */

    const marqueeTrack = document.querySelector(".marquee-track");

    if (marqueeTrack) {

        const marqueeLoop = gsap.to(marqueeTrack, {
            xPercent: -50,
            duration: 34,
            ease: "none",
            repeat: -1
        });

        let settleTimer = 0;
        let hovering = false;

        ScrollTrigger.create({
            start: 0,
            end: "max",
            onUpdate: function (self) {

                if (hovering) {
                    return;
                }

                const speed = 1 + Math.min(Math.abs(self.getVelocity()) / 250, 6);

                gsap.to(marqueeLoop, { timeScale: speed, duration: 0.25, overwrite: true });

                clearTimeout(settleTimer);
                settleTimer = setTimeout(function () {
                    gsap.to(marqueeLoop, { timeScale: 1, duration: 1.2, ease: "power2.out", overwrite: true });
                }, 140);
            }
        });

        if (finePointer) {

            const marquee = marqueeTrack.parentElement;

            marquee.addEventListener("mouseenter", function () {
                hovering = true;
                gsap.to(marqueeLoop, { timeScale: 0.15, duration: 0.6, overwrite: true });
            });

            marquee.addEventListener("mouseleave", function () {
                hovering = false;
                gsap.to(marqueeLoop, { timeScale: 1, duration: 0.8, overwrite: true });
            });
        }
    }


    /* =====================================================
       NAVIGATION — progress line and active section
    ====================================================== */

    const navProgress = document.querySelector(".nav-progress");

    if (navProgress) {
        gsap.to(navProgress, {
            scaleX: 1,
            ease: "none",
            scrollTrigger: { start: 0, end: "max", scrub: 0.3 }
        });
    }

    const navLinks = document.querySelectorAll("[data-nav-link]");

    function setActiveNav(key) {
        navLinks.forEach(function (link) {
            const active = link.dataset.navLink === key;
            link.classList.toggle("is-active", active);
            if (active) {
                link.setAttribute("aria-current", "true");
            } else {
                link.removeAttribute("aria-current");
            }
        });
    }

    document.querySelectorAll("[data-nav-section]").forEach(function (section) {
        ScrollTrigger.create({
            trigger: section,
            start: "top 45%",
            end: "bottom 45%",
            onToggle: function (self) {
                if (self.isActive) {
                    setActiveNav(section.dataset.navSection);
                }
            }
        });
    });

    ScrollTrigger.create({
        trigger: "#main",
        start: "top 45%",
        onLeaveBack: function () {
            setActiveNav(null);
        }
    });

    if (hero) {
        ScrollTrigger.create({
            start: 40,
            end: "max",
            onToggle: function (self) {
                hero.classList.toggle("is-scrolled", self.isActive);
            }
        });
    }


    /* =====================================================
       MAGNETIC BUTTONS
    ====================================================== */

    function magnetic(element, strength) {

        const xTo = gsap.quickTo(element, "x", { duration: 0.7, ease: "elastic.out(1, 0.45)" });
        const yTo = gsap.quickTo(element, "y", { duration: 0.7, ease: "elastic.out(1, 0.45)" });

        element.addEventListener("pointermove", function (event) {
            const rect = element.getBoundingClientRect();
            xTo((event.clientX - rect.left - rect.width / 2) * strength);
            yTo((event.clientY - rect.top - rect.height / 2) * strength);
        });

        element.addEventListener("pointerleave", function () {
            xTo(0);
            yTo(0);
        });
    }

    if (finePointer) {
        document.querySelectorAll("[data-magnetic]").forEach(function (element) {
            magnetic(element, 0.28);
        });
    }


    /* =====================================================
       HERO INTRO
    ====================================================== */

    function introHero() {

        if (!hero) {
            return;
        }

        const title = hero.querySelector(".hero-title");
        const items = hero.querySelectorAll("[data-hero-item]");
        const timeline = gsap.timeline({ defaults: { ease: "expo.out" } });

        if (title) {

            if (hasSplit) {

                const split = new SplitText(title, {
                    type: "words,chars",
                    charsClass: "hero-char"
                });

                timeline.from(split.chars, {
                    yPercent: 80,
                    rotateX: -85,
                    opacity: 0,
                    transformOrigin: "50% 100%",
                    transformPerspective: 900,
                    duration: 1.3,
                    stagger: 0.03
                }, 0.15);

            } else {

                timeline.from(title, { y: 40, opacity: 0, duration: 1.2 }, 0.15);
            }

            gsap.set(title, { visibility: "visible" });
        }

        timeline.to(items, { opacity: 1, y: 0, duration: 1.1, stagger: 0.08 }, 0.45);
    }

    const fontsReady = document.fonts && document.fonts.ready ? document.fonts.ready : Promise.resolve();

    Promise.race([
        fontsReady,
        new Promise(function (resolve) { setTimeout(resolve, 1500); })
    ]).then(introHero);


    /* =====================================================
       REFRESH + ARRIVING WITH A #HASH
    ====================================================== */

    fontsReady.then(function () {
        ScrollTrigger.refresh();
    });

    window.addEventListener("load", function () {

        ScrollTrigger.refresh();

        const target = findTarget(window.location.hash);

        if (target) {
            requestAnimationFrame(function () {
                scrollToTarget(target, true);
            });
        }
    });

})();
