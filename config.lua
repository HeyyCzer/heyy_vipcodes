vehicles = {
    -- concessionária
    ["conce"] = {
        name = "Carros Comuns",
        concessionaria = true
    },
    -- importados
    ["imports"] = {
        name = "Carros Importados",
        vehList = {}
    },
    -- vip
    ["vip"] = {
        name = "Carros VIPs",
        vehList = {"r1250", "s1000rr", "ferrariitalia", "teslaprior", "porsche992", "i8", "nissantitan17", "bolide",
                   "gt17", "nissangtrnismo", "488gtb", "veneno", "fc15", "lamborghinihuracan", "911r", "audirs7", "audirs6", "bc", "amggtr", "2018zl1", "aperta", "fxxkevo", "lp700r", "g65amg", "rmodgt63"}
    },
    -- ultimate
    ["ultimate"] = {
        name = "Carros Ultimate",
        vehList = {"r8ppi", "lancerevolutionx", "nissanskyliner34", "nissangtr", "senna", "toyotasupra"}
    },
    -- premium
    ["premium"] = {
        name = "Carros Premium",
        vehList = {"18velar", "urus", "rmodx6", "grandgt18"}
    },

    -- PROMOÇÃO
    ["tiktok"] = {
        name = "Carros Promocionais",
        vehList = {"t20", "elegy", "nero", "akuma"}
    }
}

vips = {
    ["booster1"] = {
        dinheiro = 50000
    },
    ["booster2"] = {
        setagem = "bronze",
        dinheiro = 75000
    },
    ["bronze"] = {
        setagem = "bronze",
        dinheiro = 25000
    },
    ["prata"] = {
        setagem = "prata",
        dinheiro = 50000,
        veiculos = {
            ["conce"] = 1
        }
    },
    ["pratafree"] = {
        setagem = "prata"
    },
    ["ouro"] = {
        setagem = "ouro",
        dinheiro = 75000,
        veiculos = {
            ["vip"] = 1
        }
    },
    ["ourofree"] = {
        setagem = "ourofree"
    },
    ["platina"] = {
        setagem = "platina",
        dinheiro = 100000,
        veiculos = {
            ["conce"] = 2,
            ["vip"] = 1
        }
    },
    ["rubi"] = {
        setagem = "ruby",
        dinheiro = 125000,
        veiculos = {
            ["conce"] = 1,
            ["vip"] = 2
        }
    },
    ["ultimate"] = {
        setagem = "ultimate",
        dinheiro = 150000,
        veiculos = {
            ["conce"] = 2,
            ["vip"] = 2,
            ["ultimate"] = 1
        }
    },
    ["premium"] = {
        setagem = "premium",
        dinheiro = 3500000,
        veiculos = {
            ["conce"] = 3,
            ["vip"] = 3,
            ["ultimate"] = 2,
            ["premium"] = 1
        }
    }
}
