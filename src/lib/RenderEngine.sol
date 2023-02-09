// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";

library RenderEngine {
    function _shortenAddr(address addr) private pure returns (string memory) {
        uint256 value = uint160(addr);
        bytes memory allBytes = bytes(Strings.toHexString(value, 20));

        string memory newString = string(allBytes);

        return
            string(
                abi.encodePacked(
                    _substring(newString, 0, 6),
                    unicode"…",
                    _substring(newString, 38, 42)
                )
            );
    }

    function _substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    string constant P1 =
        '<svg width="1060" height="600" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1058 2v596H2V81.829L81.865 2H1058z" fill="url(#prefix__paint0)" stroke="url(#prefix__paint1)" stroke-width="4"/><path d="M1056 10H74v2h982v-2zM66 18h990v2H66v-2zM4 146h1052v2H4v-2zM1056 50H34v2h1022v-2zM5.996 178H1056v2H5.996v-2zM1056 82H4v2h1052v-2zM5.996 282H1056v2H5.996v-2zM1056 210H5.996v2H1056v-2zM4 114h1052v2H4v-2zM1056 242H5.996v2H1056v-2zM50 34h1006v2H50v-2zM1056 162H5.996v2H1056v-2zM18 66h1038v2H18v-2zM1056 266H5.996v2H1056v-2zM5.996 194H1056v2H5.996v-2zM1056 98H4v2h1052v-2zM5.996 226H1056v2H5.996v-2zM1056 130H4v2h1052v-2zM5.996 258H1056v2H5.996v-2zM4 138h1052v2H4v-2zM1056 42H42v2h1014v-2zM5.996 170H1056v2H5.996v-2zM1056 74H10v2h1046v-2zM5.996 274H1056v2H5.996v-2zM1056 202H5.996v2H1056v-2zM4 106h1052v2H4v-2zM1056 234H5.996v2H1056v-2zM58 26h998v2H58v-2zM1056 154H5.996v2H1056v-2zM26 58h1030v2H26v-2zM1056 186H5.996v2H1056v-2zM4 90h1052v2H4v-2zM1056 290H5.996v2H1056v-2zM5.996 218H1056v2H5.996v-2zM1056 122H4v2h1052v-2zM5.996 250H1056v2H5.996v-2zM4 298h1052v2H4v-2zM1056 306H4v2h1052v-2zM1056 434H4v2h1052v-2zM4 338h1052v2H4v-2zM1056 466H5.996v2H1056v-2zM4 370h1052v2H4v-2zM5.996 498H1056v2H5.996v-2zM1056 402H4v2h1052v-2zM5.996 530H1056v2H5.996v-2zM1056 322H4v2h1052v-2zM5.996 450H1056v2H5.996v-2zM1056 354H4v2h1052v-2zM5.996 554H1056v2H5.996v-2zM1056 482H5.996v2H1056v-2zM4 386h1052v2H4v-2zM1056 514H5.996v2H1056v-2zM4 418h1052v2H4v-2zM1056 546H5.996v2H1056v-2zM1056 426H4v2h1052v-2zM4 330h1052v2H4v-2zM1056 458H5.996v2H1056v-2zM4 362h1052v2H4v-2zM1056 562H5.996v2H1056v-2zM5.996 490H1056v2H5.996v-2zM1056 394H4v2h1052v-2zM5.996 522H1056v2H5.996v-2zM1056 314H4v2h1052v-2zM5.996 442H1056v2H5.996v-2zM1056 346H4v2h1052v-2zM5.996 474H1056v2H5.996v-2zM1056 378H4v2h1052v-2zM5.996 578H1056v2H5.996v-2zM1056 586H5.996v2H1056v-2zM5.996 506H1056v2H5.996v-2zM1056 410H4v2h1052v-2zM5.996 538H1056v2H5.996v-2z" fill="url(#prefix__paint2)"/><path d="M1060 10V0H81L0 81v14.47L85.47 10H1060z" fill="#F98701"/><text dx="533" dy="521" dominant-baseline="central" text-anchor="middle" style="height:100px" font-family="VT323" font-size="56" fill="#FF8A01">Seed: ';
    string constant P2 =
        '</text><text dx="204" dy="252" dominant-baseline="central" text-anchor="middle" font-family="Black Ops One" font-weight="400" font-size="48" fill="#FF8A01">LifeScore</text><text dx="180" dy="144" dominant-baseline="central" text-anchor="middle" font-family="Black Ops One" font-weight="400" font-size="168" fill="#FF8A01">';
    string constant P3 =
        '</text><text dx="570" dy="385" dominant-baseline="central" text-anchor="left" font-family="VT323" font-weight="100" font-size="72" fill="#65E250">Re:';
    string constant P4 =
        '</text><text dx="803" dy="385" dominant-baseline="central" text-anchor="left" font-family="VT323" font-weight="400" font-size="72" fill="#65E250">Age:';
    string constant P5 =
        '</text><text dx="327" dy="384" dominant-baseline="central" text-anchor="middle" font-family="VT323" textLength="315" font-weight="400" font-size="72" fill="#FFF">';
    string constant P6 =
        '</text><rect x="64" y="344" width="80" height="80" rx="40" fill="url(#prefix__pattern0)"/><text dx="710" dy="85" dominant-baseline="central" text-anchor="middle" style="height:100px" font-family="Black Ops One" font-size="48" fill="#FF8A01">Degen</text><text dx="908" dy="85" dominant-baseline="central" text-anchor="middle" style="height:100px" font-family="Black Ops One" font-size="48" fill="#FF8A01">Reborn</text><text dx="755" dy="169" dominant-baseline="central" text-anchor="end" font-family="VT323" font-weight="500" font-size="80" fill="#FF4040">-';
    string constant P7 =
        '</text><text dx="765" dy="169" dominant-baseline="central" font-family="VT323" font-weight="500" font-size="80" fill="#65E250">+';
    string constant P8 =
        '</text><path fill="#FFD058" d="M949 148v5h-5v-5z"/><path fill="#E86609" d="M969 148v5h-5v-5z"/><path fill="#F8C156" d="M989 148v5h-5v-5z"/><path fill="#fff" d="M939 148v5h-5v-5z"/><path fill="#E86609" d="M959 148v5h-5v-5z"/><path fill="#F8C156" d="M979 148v5h-5v-5z"/><path fill="#000" d="M999 148v5h-5v-5zM934 148v5h-5v-5z"/><path fill="#FFD058" d="M954 148v5h-5v-5z"/><path fill="#C04A07" d="M974 148v5h-5v-5z"/><path fill="#F29914" d="M994 148v5h-5v-5z"/><path fill="#FFD058" d="M944 148v5h-5v-5z"/><path fill="#E86609" d="M964 148v5h-5v-5z"/><path fill="#F8C156" d="M984 148v5h-5v-5z"/><path fill="#fff" d="M949 138v5h-5v-5z"/><path fill="#F8C156" d="M969 138v5h-5v-5z"/><path fill="#000" d="M989 138v5h-5v-5z"/><path fill="#FFD058" d="M959 138v5h-5v-5z"/><path fill="#F29914" d="M979 138v5h-5v-5z"/><path fill="#fff" d="M954 138v5h-5v-5z"/><path fill="#F8C156" d="M974 138v5h-5v-5z"/><path fill="#000" d="M944 138v5h-5v-5z"/><path fill="#FFD058" d="M964 138v5h-5v-5z"/><path fill="#F29914" d="M984 138v5h-5v-5z"/><path fill="#000" d="M954 128h5v5h-5zM929 158v5h-5v-5z"/><path fill="#FFD058" d="M949 158v5h-5v-5z"/><path fill="#F8C156" d="M969 158v5h-5v-5zM989 158v5h-5v-5z"/><path fill="#FFD058" d="M939 158v5h-5v-5z"/><path fill="#C04A07" d="M959 158v5h-5v-5zM979 158v5h-5v-5z"/><path fill="#F29914" d="M999 158v5h-5v-5z"/><path fill="#fff" d="M934 158v5h-5v-5z"/><path fill="#E86609" d="M954 158v5h-5v-5zM974 158v5h-5v-5z"/><path fill="#F8C156" d="M994 158v5h-5v-5z"/><path fill="#FFD058" d="M944 158v5h-5v-5zM964 158v5h-5v-5z"/><path fill="#F8C156" d="M984 158v5h-5v-5z"/><path fill="#000" d="M1004 158v5h-5v-5zM949 133v5h-5v-5z"/><path fill="#F29914" d="M969 133v5h-5v-5z"/><path fill="#fff" d="M959 133v5h-5v-5z"/><path fill="#000" d="M979 133v5h-5v-5zM954 133v5h-5v-5z"/><path fill="#F29914" d="M974 133v5h-5v-5z"/><path fill="#fff" d="M964 133v5h-5v-5z"/><path fill="#000" d="M984 133v5h-5v-5z"/><path fill="#FFD058" d="M949 153v5h-5v-5z"/><path fill="#F8C056" d="M969 153v5h-5v-5z"/><path fill="#F8C156" d="M989 153v5h-5v-5z"/><path fill="#fff" d="M939 153v5h-5v-5z"/><path fill="#C04A07" d="M959 153v5h-5v-5zM979 153v5h-5v-5z"/><path fill="#000" d="M999 153v5h-5v-5zM934 153v5h-5v-5z"/><path fill="#E86609" d="M954 153v5h-5v-5zM974 153v5h-5v-5z"/><path fill="#F29914" d="M994 153v5h-5v-5z"/><path fill="#FFD058" d="M944 153v5h-5v-5zM964 153v5h-5v-5z"/><path fill="#F8C156" d="M984 153v5h-5v-5z"/><path fill="#FFD058" d="M949 143v5h-5v-5z"/><path fill="#F8C156" d="M969 143v5h-5v-5z"/><path fill="#F29914" d="M989 143v5h-5v-5z"/><path fill="#000" d="M939 143v5h-5v-5z"/><path fill="#FFD058" d="M959 143v5h-5v-5z"/><path fill="#F8C156" d="M979 143v5h-5v-5z"/><path fill="#FFD058" d="M954 143v5h-5v-5z"/><path fill="#F8C156" d="M974 143v5h-5v-5z"/><path fill="#000" d="M994 143v5h-5v-5z"/><path fill="#fff" d="M944 143v5h-5v-5z"/><path fill="#FFD058" d="M964 143v5h-5v-5z"/><path fill="#F8C156" d="M984 143v5h-5v-5z"/><path fill="#000" d="M959 128h5v5h-5zM929 163v5h-5v-5z"/><path fill="#FFD058" d="M949 163v5h-5v-5z"/><path fill="#E86609" d="M969 163v5h-5v-5z"/><path fill="#F8C156" d="M989 163v5h-5v-5z"/><path fill="#FFD058" d="M939 163v5h-5v-5z"/><path fill="#E86609" d="M959 163v5h-5v-5z"/><path fill="#F8C156" d="M979 163v5h-5v-5z"/><path fill="#F29914" d="M999 163v5h-5v-5z"/><path fill="#fff" d="M934 163v5h-5v-5z"/><path fill="#E86609" d="M954 163v5h-5v-5z"/><path fill="#C04A07" d="M974 163v5h-5v-5z"/><path fill="#F8C156" d="M994 163v5h-5v-5z"/><path fill="#FFD058" d="M944 163v5h-5v-5z"/><path fill="#E86609" d="M964 163v5h-5v-5z"/><path fill="#F8C156" d="M984 163v5h-5v-5z"/><path fill="#000" d="M1004 163v5h-5v-5zM964 128h5v5h-5zM929 168v5h-5v-5z"/><path fill="#FFD058" d="M949 168v5h-5v-5z"/><path fill="#F8C056" d="M969 168v5h-5v-5z"/><path fill="#F8C156" d="M989 168v5h-5v-5z"/><path fill="#FFD058" d="M939 168v5h-5v-5z"/><path fill="#C04A07" d="M959 168v5h-5v-5zM979 168v5h-5v-5z"/><path fill="#F29914" d="M999 168v5h-5v-5z"/><path fill="#fff" d="M934 168v5h-5v-5z"/><path fill="#E86609" d="M954 168v5h-5v-5zM974 168v5h-5v-5z"/><path fill="#F8C156" d="M994 168v5h-5v-5z"/><path fill="#FFD058" d="M944 168v5h-5v-5zM964 168v5h-5v-5z"/><path fill="#F8C156" d="M984 168v5h-5v-5z"/><path fill="#000" d="M1004 168v5h-5v-5z"/><path fill="#FFD058" d="M949 188v5h-5v-5z"/><path fill="#F8C156" d="M969 188v5h-5v-5z"/><path fill="#F29914" d="M989 188v5h-5v-5z"/><path fill="#000" d="M939 188v5h-5v-5z"/><path fill="#FFD058" d="M959 188v5h-5v-5z"/><path fill="#F8C156" d="M979 188v5h-5v-5z"/><path fill="#FFD058" d="M954 188v5h-5v-5z"/><path fill="#F8C156" d="M974 188v5h-5v-5z"/><path fill="#000" d="M994 188v5h-5v-5z"/><path fill="#fff" d="M944 188v5h-5v-5z"/><path fill="#FFD058" d="M964 188v5h-5v-5z"/><path fill="#F8C156" d="M984 188v5h-5v-5z"/><path fill="#FFD058" d="M949 178v5h-5v-5z"/><path fill="#F8C156" d="M969 178v5h-5v-5zM989 178v5h-5v-5z"/><path fill="#fff" d="M939 178v5h-5v-5z"/><path fill="#C04A07" d="M959 178v5h-5v-5z"/><path fill="#E86609" d="M979 178v5h-5v-5z"/><path fill="#000" d="M999 178v5h-5v-5zM934 178v5h-5v-5z"/><path fill="#E86609" d="M954 178v5h-5v-5z"/><path fill="#F8C056" d="M974 178v5h-5v-5z"/><path fill="#F29914" d="M994 178v5h-5v-5z"/><path fill="#FFD058" d="M944 178v5h-5v-5zM964 178v5h-5v-5z"/><path fill="#C04A07" d="M984 178v5h-5v-5z"/><path fill="#000" d="M949 198v5h-5v-5z"/><path fill="#F29914" d="M969 198v5h-5v-5z"/><path fill="#FFE6A6" d="M959 198v5h-5v-5z"/><path fill="#000" d="M979 198v5h-5v-5zM954 198v5h-5v-5z"/><path fill="#F29914" d="M974 198v5h-5v-5z"/><path fill="#FFE6A6" d="M964 198v5h-5v-5z"/><path fill="#000" d="M984 198v5h-5v-5zM969 128h5v5h-5zM929 173v5h-5v-5z"/><path fill="#FFD058" d="M949 173v5h-5v-5z"/><path fill="#F8C056" d="M969 173v5h-5v-5z"/><path fill="#F8C156" d="M989 173v5h-5v-5z"/><path fill="#FFD058" d="M939 173v5h-5v-5z"/><path fill="#C04A07" d="M959 173v5h-5v-5zM979 173v5h-5v-5z"/><path fill="#F29914" d="M999 173v5h-5v-5z"/><path fill="#fff" d="M934 173v5h-5v-5z"/><path fill="#E86609" d="M954 173v5h-5v-5zM974 173v5h-5v-5z"/><path fill="#F8C156" d="M994 173v5h-5v-5z"/><path fill="#FFD058" d="M944 173v5h-5v-5zM964 173v5h-5v-5z"/><path fill="#F8C156" d="M984 173v5h-5v-5z"/><path fill="#000" d="M1004 173v5h-5v-5z"/><path fill="#fff" d="M949 193v5h-5v-5z"/><path fill="#F8C156" d="M969 193v5h-5v-5z"/><path fill="#000" d="M989 193v5h-5v-5z"/><path fill="#FFD058" d="M959 193v5h-5v-5z"/><path fill="#F29914" d="M979 193v5h-5v-5z"/><path fill="#fff" d="M954 193v5h-5v-5z"/><path fill="#F8C156" d="M974 193v5h-5v-5z"/><path fill="#000" d="M944 193v5h-5v-5z"/><path fill="#FFD058" d="M964 193v5h-5v-5z"/><path fill="#F29914" d="M984 193v5h-5v-5z"/><path fill="#FFD058" d="M949 183v5h-5v-5z"/><path fill="#F8C156" d="M969 183v5h-5v-5zM989 183v5h-5v-5z"/><path fill="#fff" d="M939 183v5h-5v-5z"/><path fill="#FFD058" d="M959 183v5h-5v-5z"/><path fill="#F8C056" d="M979 183v5h-5v-5z"/><path fill="#000" d="M999 183v5h-5v-5zM934 183v5h-5v-5z"/><path fill="#FFD058" d="M954 183v5h-5v-5z"/><path fill="#F8C156" d="M974 183v5h-5v-5z"/><path fill="#F29914" d="M994 183v5h-5v-5z"/><path fill="#FFD058" d="M944 183v5h-5v-5zM964 183v5h-5v-5z"/><path fill="#F8C056" d="M984 183v5h-5v-5z"/><path fill="#000" d="M969 203v5h-5v-5zM959 203v5h-5v-5zM974 203v5h-5v-5zM964 203v5h-5v-5z"/><defs><linearGradient id="prefix__paint0" x1="530.037" y1="-2" x2="530.037" y2="578" gradientUnits="userSpaceOnUse"><stop stop-color="#452F16"/><stop offset="1" stop-color="#1B2023"/></linearGradient><linearGradient id="prefix__paint1" x1="530.037" y1="-2" x2="530.037" y2="570" gradientUnits="userSpaceOnUse"><stop stop-color="#FF8A00"/><stop offset="1" stop-color="#52391B"/></linearGradient><linearGradient id="prefix__paint2" x1="530.998" y1="0" x2="530.998" y2="298" gradientUnits="userSpaceOnUse"><stop stop-color="#F78602" stop-opacity=".35"/><stop offset="1" stop-color="#F78602" stop-opacity="0"/></linearGradient><style>@font-face{font-family:&quot;VT323&quot;;font-style:normal;font-weight:400;src:url(data:application/font;base64,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) format(&apos;woff2&apos;)}</style><style>@font-face{font-family:&apos;Black Ops One&apos;;src:url(data:application/font;base64,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) format(&apos;woff2&apos;)}</style></defs></svg>';

    function render(
        string calldata seed,
        uint256 lifeScore,
        uint256 round,
        uint256 age,
        address addr,
        uint256 pay,
        uint256 reward
    ) public pure returns (string memory) {
        string memory Part1 = _renderPart1(seed, lifeScore, round, age);
        string memory Part2 = _renderPart2(addr, pay, reward);
        return string(abi.encodePacked(Part1, Part2));
    }

    function _renderPart1(
        string calldata seed,
        uint256 lifeScore,
        uint256 round,
        uint256 age
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    P1,
                    seed,
                    P2,
                    Strings.toString(lifeScore),
                    P3,
                    Strings.toString(round),
                    P4,
                    Strings.toString(age)
                )
            );
    }

    function _renderPart2(
        address addr,
        uint256 pay,
        uint256 reward
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    P5,
                    _shortenAddr(addr),
                    P6,
                    Strings.toString(pay),
                    P7,
                    Strings.toString(reward),
                    P8
                )
            );
    }
}
