import 'package:flutter/material.dart';
import '../models/quest_model.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';

class QuestDetailScreen extends StatelessWidget {
  final Quest quest;

  const QuestDetailScreen({
    super.key,
    required this.quest,
  });

  String _getQuestDescription() {
    // Mappa delle descrizioni dettagliate per ogni quest
    final descriptions = {
      'Quest del Colosseo': '''
L'Anfiteatro Flavio, meglio conosciuto come Colosseo, è il più grande anfiteatro del mondo romano, costruito tra il 70 e l'80 d.C.

🏛️ Storia e Importanza
• Costruzione iniziata sotto l'imperatore Vespasiano nel 70 d.C.
• Completato sotto Tito nell'80 d.C.
• Poteva ospitare tra 50.000 e 75.000 spettatori
• È stato utilizzato per quasi 500 anni per spettacoli pubblici

🔨 Stato di Conservazione
• Il monumento ha subito danni significativi da terremoti e spoliazioni
• Il 40% della struttura originale è andata perduta
• L'inquinamento atmosferico continua a minacciare la pietra calcarea

🌍 Impatto della Community
La tua partecipazione a questa quest contribuisce a:
• Monitoraggio dello stato di conservazione
• Documentazione fotografica dei cambiamenti nel tempo
• Sensibilizzazione sull'importanza della preservazione
• Creazione di un database storico collaborativo

📅 Date Significative
70 d.C. - Inizio costruzione
80 d.C. - Inaugurazione
217 d.C. - Primo restauro documentato
1349 - Grave danno da terremoto
2011-2016 - Maggiore restauro moderno''',
      'Quest della Torre di Pisa': '''
La Torre pendente di Pisa, campanile della cattedrale cittadina, è uno dei monumenti italiani più iconici e un incredibile esempio di architettura romanica.

🏛️ Storia e Importanza
• Costruzione iniziata nel 1173
• La pendenza iniziò durante la costruzione del terzo piano
• È alta 56,7 metri e pende di circa 3,9 gradi

🔨 Sfide di Conservazione
• La torre continua a muoversi leggermente ogni anno
• Il terreno instabile rimane una sfida costante
• Interventi di stabilizzazione sono stati cruciali

🌍 Impatto della Community
Il tuo contributo aiuta a:
• Monitorare i cambiamenti nell'inclinazione
• Documentare l'efficacia degli interventi di stabilizzazione
• Creare consapevolezza sulle sfide di conservazione

📅 Eventi Chiave
1173 - Inizio costruzione
1278 - Ripresa dei lavori
1372 - Completamento
1990-2001 - Importante intervento di stabilizzazione
2008 - Dichiarazione di stabilità''',
      'Quest del Pantheon': '''
Il Pantheon, tempio di tutti gli dei, è uno dei monumenti antichi meglio conservati di Roma e un capolavoro dell'architettura romana.

🏛️ Storia e Importanza
• Costruito tra il 118 e il 125 d.C. sotto Adriano
• La cupola è ancora oggi la più grande cupola in calcestruzzo non armato
• È stato un tempio pagano poi convertito in chiesa

🔨 Stato di Conservazione
• Eccezionalmente ben conservato grazie all'uso continuo
• La cupola rappresenta un miracolo di ingegneria antica
• Il sistema di drenaggio originale è ancora funzionante

🌍 Ruolo della Community
Partecipando contribuisci a:
• Documentare lo stato di conservazione
• Studiare le tecniche costruttive romane
• Preservare la memoria storica

📅 Timeline Storica
118 d.C. - Inizio costruzione
125 d.C. - Completamento
609 d.C. - Conversione in chiesa
1870 - Diventa monumento nazionale
2020 - Ultimo restauro maggiore''',
      'Quest del Roman Forum': '''
Il Foro Romano, cuore pulsante dell'antica Roma, è stato per secoli il centro della vita pubblica, religiosa e commerciale dell'Impero.

🏛️ Importanza Storica
• Centro politico dell'antica Roma
• Sede dei principali templi e edifici governativi
• Testimonianza dell'evoluzione architettonica romana

🔨 Conservazione e Restauro
• Area archeologica in continuo studio
• Sfide di conservazione dovute all'esposizione agli agenti atmosferici
• Necessità di bilanciare accesso pubblico e preservazione

🌍 Impatto Collettivo
La tua partecipazione contribuisce a:
• Mappare i cambiamenti nel tempo
• Documentare lo stato dei monumenti
• Creare consapevolezza sulla preservazione

📅 Date Chiave
509 a.C. - Primi edifici pubblici
46 a.C. - Maggiori sviluppi sotto Giulio Cesare
283 d.C. - Ultimo edificio costruito
1898 - Inizio degli scavi sistematici
2000-oggi - Continui progetti di conservazione''',
    };

    return descriptions[quest.title] ??
        'Informazioni dettagliate su questa quest saranno presto disponibili.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 122),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppTheme.primaryColor,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                quest.imagePath,
                fit: BoxFit.cover,
              ),
              title: Text(
                quest.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descrizione della Quest',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    _getQuestDescription(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              latitude: quest.latitude,
                              longitude: quest.longitude,
                              questTitle: quest.title,
                              showBackButton: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Apri Navigazione'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
