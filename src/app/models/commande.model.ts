import { Livraison } from "./livraison.model";
import { Produit } from "./produit.model";

export interface Commande {
  id?: number;
  dateCommande?: string;
  clientId: number;
  statut: 'EN_ATTENTE' | 'CONFIRMEE';
  total: number;
  produits?: CommandeProduit[];
  livraison?: Livraison;
}

export interface CommandeProduit {
  id?: number;
  quantite: number;
  prixUnitaire: number;
  produit: Produit;
}