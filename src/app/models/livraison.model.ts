export interface Livraison {
  id?: number;
  adresseLivraison: string;
  statut: 'EN_ATTENTE' | 'EN_COURS' | 'LIVREE' | 'ANNULEE';
}