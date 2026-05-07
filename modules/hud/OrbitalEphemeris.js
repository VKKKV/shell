.pragma library

// Gaussian gravitational constant squared in AU^3/day^2. Used as the solar GM for visual ephemeris mean motion.
var gmSun = 2.959122082855911e-4;
var centuryDays = 36525;

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value));
}

function wrap360(value) {
    var wrapped = value % 360;
    return wrapped < 0 ? wrapped + 360 : wrapped;
}

function degToRad(value) {
    return value * Math.PI / 180;
}

function radToDeg(value) {
    return value * 180 / Math.PI;
}

function elementValue(p, baseName, rateName, centuries) {
    var base = typeof p[baseName] === "number" ? p[baseName] : 0;
    var rate = typeof p[rateName] === "number" ? p[rateName] : 0;
    return base + rate * centuries;
}

function meanMotion(a) {
    return Math.sqrt(gmSun / (a * a * a)) * (180 / Math.PI);
}

function elementsFor(p, dayOffset) {
    var centuries = dayOffset / centuryDays;
    var a = Math.max(0.0001, elementValue(p, "a", "da", centuries));
    var e = clamp(elementValue(p, "e", "de", centuries), 0, 0.4);
    var inc = elementValue(p, "i", "di", centuries);
    var node = wrap360(elementValue(p, "node", "dnode", centuries));
    var peri = wrap360(elementValue(p, "peri", "dperi", centuries));
    var meanLongitude = wrap360(elementValue(p, "meanLongitude", "dmeanLongitude", centuries));
    var m0 = wrap360(meanLongitude - peri);
    var n = meanMotion(a);
    return { a: a, e: e, i: inc, node: node, peri: peri, meanLongitude: meanLongitude, m0: m0, n: n, centuries: centuries };
}

function planetSize(p) {
    return typeof p.size === "number" && p.size > 0 ? p.size : 7;
}

function solveKepler(meanAnomalyDeg, e) {
    var m = degToRad(meanAnomalyDeg);
    var E = m + e * Math.sin(m) / (1 - Math.sin(m + e) + Math.sin(m));
    for (var step = 0; step < 20; step++) {
        var dE = (E - e * Math.sin(E) - m) / (1 - e * Math.cos(E));
        E -= dE;
        if (Math.abs(dE) < 1e-12)
            break;
    }
    return E;
}

function orbitalState(p, dayOffset) {
    var el = elementsFor(p, dayOffset);
    var a = el.a;
    var e = el.e;
    var inc = degToRad(el.i);
    var node = degToRad(el.node);
    var peri = degToRad(el.peri);
    var M = el.m0;
    var E = solveKepler(M, e);
    var cosE = Math.cos(E);
    var sinE = Math.sin(E);
    var xv = a * (cosE - e);
    var yv = a * Math.sqrt(1 - e * e) * sinE;
    var nu = Math.atan2(yv, xv);
    var r = Math.sqrt(xv * xv + yv * yv);

    var arg = nu + peri - node;
    var cosNode = Math.cos(node);
    var sinNode = Math.sin(node);
    var cosArg = Math.cos(arg);
    var sinArg = Math.sin(arg);
    var cosI = Math.cos(inc);
    var sinI = Math.sin(inc);

    var x = r * (cosNode * cosArg - sinNode * sinArg * cosI);
    var y = r * (sinNode * cosArg + cosNode * sinArg * cosI);
    var z = r * (sinArg * sinI);

    var eclLon = wrap360(radToDeg(Math.atan2(y, x)));
    var eclLat = radToDeg(Math.atan2(z, Math.sqrt(x * x + y * y)));

    return {
        x: x, y: y, z: z, r: r,
        eclLon: eclLon, eclLat: eclLat,
        trueAnomaly: wrap360(radToDeg(nu)),
        meanAnomaly: wrap360(M),
        eccentricAnomaly: wrap360(radToDeg(E)),
        elements: el
    };
}

function zodiacIndex(eclLon) {
    return Math.floor(wrap360(eclLon) / 30);
}

function phaseAngle(planetXYZ, earthXYZ) {
    var dx = earthXYZ.x - planetXYZ.x;
    var dy = earthXYZ.y - planetXYZ.y;
    var dz = earthXYZ.z - planetXYZ.z;
    var distEarth = Math.sqrt(dx * dx + dy * dy + dz * dz);
    if (distEarth < 1e-9)
        return 0;
    var dot = -(dx * planetXYZ.x + dy * planetXYZ.y + dz * planetXYZ.z) / (distEarth * planetXYZ.r);
    return radToDeg(Math.acos(clamp(dot, -1, 1)));
}

function apparentMagnitude(p, rHelio, distEarth, phaseDeg) {
    var absMag = typeof p.mag0 === "number" ? p.mag0 : -3.9;
    var safeDistance = Math.max(0.0001, distEarth);
    var phaseTerm = Math.max(0, phaseDeg) * 0.013;
    return absMag + 5 * Math.log10(Math.max(0.0001, rHelio * safeDistance)) + phaseTerm;
}
