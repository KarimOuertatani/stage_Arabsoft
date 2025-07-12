import { Component, OnInit, ViewChild, HostListener } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
  ]
})
export class ProductsComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  produits: Produit[] = [];
  produitColumns = ['id', 'nom', 'categorie', 'prix', 'quantite', 'actions'];
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  productChartData: ChartData<'pie'> = {
    labels: [],
    datasets: [
      {
        data: [],
        backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'right',
        labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } }
      },
      tooltip: {
        enabled: true,
        backgroundColor: '#1f2a44',
        titleFont: { family: 'Inter, Roboto, sans-serif' },
        bodyFont: { family: 'Inter, Roboto, sans-serif' }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit() {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadProducts();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  private loadProducts() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getProduits().subscribe({
      next: (produits) => {
        this.produits = produits;
        this.updateChartData();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des produits:', err);
        this.errorMessage = 'Failed to load products. Please try again.';
        this.isLoading = false;
      }
    });
  }

  private updateChartData() {
    const categoryCounts = new Map<string, number>();
    this.produits.forEach(produit => {
      const category = produit.categorie.nom;
      categoryCounts.set(category, (categoryCounts.get(category) || 0) + 1);
    });
    this.productChartData.labels = Array.from(categoryCounts.keys());
    this.productChartData.datasets[0].data = Array.from(categoryCounts.values());
  }

  updateProduct(id: number) {
    console.log(`Update product with ID: ${id}`);
    // Implémenter la logique de mise à jour (ex. : naviguer vers un formulaire)
  }

  deleteProduct(id: number) {
    console.log(`Delete product with ID: ${id}`);
    // Implémenter la logique de suppression
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadProducts();
  }
}