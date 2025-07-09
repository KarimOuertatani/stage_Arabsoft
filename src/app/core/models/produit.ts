export interface Produit {
  id?: number;
  nom: string;
  description?: string;
  prix: number;
  quantite: number;
  image?: string;
  categorie: { id: number; nom: string };
  fournisseur: { id: number; nom: string; prenom: string };
}