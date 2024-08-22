List<Card__c> cardsToInsert = new List<Card__c>();
        
        // Descrições e raridades para as cartas
        List<String> descriptionsEnergy = new List<String>{
            'Fonte de Energia Vital',
            'Cristal Energético',
            'Essência de Vida',
            'Pedra Mágica',
            'Núcleo de Força',
            'Elixir Energético',
            'Chama de Energia',
            'Vórtice de Energia',
            'Fonte Elementar',
            'Joia da Energia'
        };

        List<String> descriptionsMonster = new List<String>{
            'Dragão Feroz',
            'Gigante das Sombras',
            'Lobo Místico',
            'Serpente das Trevas',
            'Golem de Pedra',
            'Fênix Flamejante',
            'Tigre das Nuvens',
            'Cavaleiro Imortal',
            'Quimera Voraz',
            'Guardião da Floresta'
        };

        // Criar cartas do tipo Energy
        for (Integer i = 0; i < 10; i++) {
            cardsToInsert.add(new Card__c(
                Name = descriptionsEnergy[i],
                Description__c = descriptionsEnergy[i],
                Rarity__c = getRandomRarity(),
                Type__c = 'Energy'
            ));
        }

        // Criar cartas do tipo Monster
        for (Integer i = 0; i < 10; i++) {
            cardsToInsert.add(new Card__c(
                Attack__c = Math.mod(i + 2, 5) + 1, // Valores entre 1 e 5
                Defense__c = Math.mod(i + 3, 5) + 1, // Valores entre 1 e 5
                Name = descriptionsMonster[i],
                Description__c = descriptionsMonster[i],
                Rarity__c = getRandomRarity(),
                Type__c = 'Monster',
                EnergyCost__c = 3
            ));
        }

        // Inserir os registros
        try {
            insert cardsToInsert;
            System.debug('Registros de cartas inseridos com sucesso.');
        } catch (Exception e) {
            System.debug('Erro ao inserir registros: ' + e.getMessage());
        }
    

    // Função auxiliar para obter uma raridade aleatória
    private static String getRandomRarity() {
        List<String> rarities = new List<String>{'Common', 'Uncommon', 'Rare', 'Ultra Rare', 'Special'};
        Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), rarities.size());
        return rarities[index];
    }