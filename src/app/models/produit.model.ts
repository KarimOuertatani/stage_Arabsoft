import { Utilisateur } from "./utilisateur.model";

export interface Produit {
  id?: number;
  nom: string;
  description?: string;
  prix: number;
  quantite: number;
  image?: string;
  categorie: Categorie;
  fournisseur: Utilisateur;
}

export interface Categorie {
  id?: number;
  nom: string;
}