import { Component, OnInit, OnDestroy } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { MtxProgressModule } from '@ng-matero/extensions/progress';
import { TranslateModule } from '@ngx-translate/core';
import { Subscription } from 'rxjs';
import { UserService } from '../../core/services/user.service';
import { ProduitService } from '../../core/services/produit.service';
import { CategorieService } from '../../core/services/categorie.service';
import { CommandeService } from '../../core/services/commande.service';
import { LivraisonService } from '../../core/services/livraison.service';

export interface Stat {
  title: string;
  amount: string;
  progress: { value: number };
  color: string;
}

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
  imports: [
    MatCardModule,
    MatGridListModule,
    MtxProgressModule,
    MtxAlertModule,
    TranslateModule
  ],
  standalone: false
})
export class DashboardComponent implements OnInit, OnDestroy {
  stats: Stat[] = [];
  isShowAlert = true;
  private subscriptions: Subscription[] = [];

  constructor(
    private userService: UserService,
    private produitService: ProduitService,
    private categorieService: CategorieService,
    private commandeService: CommandeService,
    private livraisonService: LivraisonService
  ) {}

  ngOnInit() {
    this.loadStats();
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  loadStats() {
    this.subscriptions.push(
      this.userService.getAllUsers().subscribe(users => {
        this.stats.push(
          {
            title: 'Total Utilisateurs',
            amount: users.length.toString(),
            progress: { value: 50 },
            color: 'bg-blue-500'
          },
          {
            title: 'Clients',
            amount: users.filter(u => u.typeUtilisateur === 'CLIENT').length.toString(),
            progress: { value: 60 },
            color: 'bg-green-500'
          },
          {
            title: 'Fournisseurs',
            amount: users.filter(u => u.typeUtilisateur === 'FOURNISSEUR').length.toString(),
            progress: { value: 70 },
            color: 'bg-cyan-500'
          },
          {
            title: 'Admins',
            amount: users.filter(u => u.typeUtilisateur === 'ADMIN').length.toString(),
            progress: { value: 80 },
            color: 'bg-indigo-500'
          }
        );
      })
    );

    this.subscriptions.push(
      this.produitService.getAllProduits().subscribe(produits => {
        this.stats.push({
          title: 'Produits',
          amount: produits.length.toString(),
          progress: { value: 50 },
          color: 'bg-purple-500'
        });
      })
    );

    this.subscriptions.push(
      this.categorieService.getAllCategories().subscribe(categories => {
        this.stats.push({
          title: 'Catégories',
          amount: categories.length.toString(),
          progress: { value: 40 },
          color: 'bg-orange-500'
        });
      })
    );

    this.subscriptions.push(
      this.commandeService.getAllCommandesByClient(1).subscribe(commandes => {
        this.stats.push({
          title: 'Commandes',
          amount: commandes.length.toString(),
          progress: { value: 60 },
          color: 'bg-teal-500'
        });
      })
    );

    this.subscriptions.push(
      this.livraisonService.getAllLivraisons().subscribe(livraisons => {
        this.stats.push({
          title: 'Livraisons',
          amount: livraisons.length.toString(),
          progress: { value: 70 },
          color: 'bg-red-500'
        });
      })
    );
  }

  onAlertDismiss() {
    this.isShowAlert = false;
  }
}