import { CommandeProduit } from './commande-produit';
import { Livraison } from './livraison';

export interface Commande {
  id?: number;
  dateCommande: string;
  clientId: number;
  statut: 'EN_ATTENTE' | 'CONFIRMEE';
  total: number;
  produits: CommandeProduit[];
  livraison?: Livraison;
}