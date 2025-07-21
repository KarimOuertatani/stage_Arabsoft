import { Component, OnInit, ViewChild, HostListener, Inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule, MatTableDataSource } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog, MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatPaginatorModule, MatPaginator } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { CommandeDTO } from '../models/commande.model';
import { LivraisonDTO } from '../models/livraison.model';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';
import { Categorie } from '../models/categorie.model';
import { CommonModule } from '@angular/common';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { FormsModule } from '@angular/forms';
import { SidebarComponent } from '../sidebar/sidebar.component';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatGridListModule,
    MatCardModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule,
    MatDialogModule,
    MatPaginatorModule,
    MatSelectModule,
    FormsModule,
    SidebarComponent,
  ],
})
export class DashboardComponent implements OnInit {
  @ViewChild('produitPaginator') produitPaginator!: MatPaginator;
  @ViewChild('commandePaginator') commandePaginator!: MatPaginator;

  totalCommandes: number = 0;
  totalRevenue: number = 0;
  pendingDeliveries: number = 0;
  outOfStockProducts: number = 0;
  totalProduits: number = 0;
  totalUtilisateurs: number = 0;
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  gridCols: number = 4;
  windowWidth: number = window.innerWidth;
  selectedPeriod: string = 'month';
  periodOptions = [
    { value: 'week', label: 'Last Week' },
    { value: 'month', label: 'Last Month' },
    { value: 'quarter', label: 'Last Quarter' },
  ];

  stats: { title: string; amount: number; icon: string; route: string; tooltip: string }[] = [
    { title: 'Total Orders', amount: 0, icon: 'shopping_cart', route: '/orders', tooltip: 'View all orders' },
    { title: 'Total Revenue', amount: 0, icon: 'monetization_on', route: '/orders', tooltip: 'View revenue details' },
    { title: 'Pending Deliveries', amount: 0, icon: 'local_shipping', route: '/deliveries', tooltip: 'View pending deliveries' },
    { title: 'Out of Stock', amount: 0, icon: 'warning', route: '/products', tooltip: 'View out of stock products' },
    { title: 'Total Products', amount: 0, icon: 'inventory_2', route: '/products', tooltip: 'View all products' },
    { title: 'Total Users', amount: 0, icon: 'people', route: '/users', tooltip: 'View all users' },
  ];

  categoryStats = new MatTableDataSource<{ name: string; count: number; percentage: number; id: number }>([]);
  recentCommandes = new MatTableDataSource<CommandeDTO>([]);
  recentProduits = new MatTableDataSource<Produit>([]);
  displayedProductColumns: string[] = ['image', 'nom', 'categorie', 'prix', 'quantite'];
  displayedCommandeColumns: string[] = ['id', 'client', 'total', 'statut', 'date'];

  lineChartData: ChartData<'line'> = {
    labels: [],
    datasets: [
      {
        label: 'Orders Over Time',
        data: [],
        borderColor: '#2563eb',
        backgroundColor: 'rgba(37, 99, 235, 0.2)',
        fill: true,
        tension: 0.4,
      },
    ],
  };

  lineChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'top', labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      tooltip: { enabled: true, backgroundColor: '#1f2a44', titleFont: { family: 'Inter, Roboto, sans-serif' }, bodyFont: { family: 'Inter, Roboto, sans-serif' } },
    },
    scales: {
      y: { beginAtZero: true, title: { display: true, text: 'Number of Orders', font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      x: { title: { display: true, text: 'Period', font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
    },
  };

  donutChartData: ChartData<'doughnut'> = {
    labels: ['En Attente', 'En Cours', 'Livrée', 'Annulée'],
    datasets: [
      {
        data: [0, 0, 0, 0],
        backgroundColor: ['#f59e0b', '#2563eb', '#14b8a6', '#ef4444'],
        borderColor: '#ffffff',
        borderWidth: 2,
      },
    ],
  };

  donutChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'right', labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      tooltip: { enabled: true, backgroundColor: '#1f2a44', titleFont: { family: 'Inter, Roboto, sans-serif' }, bodyFont: { family: 'Inter, Roboto, sans-serif' } },
    },
  };

  pieChartData: ChartData<'pie'> = {
    labels: [],
    datasets: [
      {
        data: [],
        backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
        borderColor: '#ffffff',
        borderWidth: 2,
      },
    ],
  };

  pieChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'right', labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      tooltip: { enabled: true, backgroundColor: '#1f2a44', titleFont: { family: 'Inter, Roboto, sans-serif' }, bodyFont: { family: 'Inter, Roboto, sans-serif' } },
    },
  };

  constructor(private apiService: ApiService, private router: Router, private dialog: MatDialog) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.gridCols = this.windowWidth <= 599 ? 1 : this.windowWidth <= 960 ? 2 : 4;
  }

  ngOnInit(): void {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.gridCols = this.windowWidth <= 599 ? 1 : this.windowWidth <= 960 ? 2 : 4;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadData();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      },
    });
  }

  ngAfterViewInit() {
    if (this.produitPaginator) {
      this.recentProduits.paginator = this.produitPaginator;
    }
    if (this.commandePaginator) {
      this.recentCommandes.paginator = this.commandePaginator;
    }
  }

  private loadData(): void {
    this.isLoading = true;
    this.errorMessage = null;

    let completedRequests = 0;
    const totalRequests = 5;

    const checkLoading = () => {
      completedRequests++;
      if (completedRequests === totalRequests) {
        this.isLoading = false;
      }
    };

    this.apiService.getCommandes().subscribe({
      next: (commandes: CommandeDTO[]) => {
        this.totalCommandes = commandes.length;
        this.totalRevenue = commandes.reduce((sum, cmd) => sum + (cmd.total || 0), 0);
        this.stats[0].amount = this.totalCommandes;
        this.stats[1].amount = this.totalRevenue;
        this.recentCommandes.data = commandes.slice(0, 5);
        this.updateLineChartData(commandes);
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des commandes:', err);
        this.errorMessage = 'Failed to load orders. Please try again.';
      },
      complete: checkLoading,
    });

    this.apiService.getLivraisons().subscribe({
      next: (livraisons: LivraisonDTO[]) => {
        this.pendingDeliveries = livraisons.filter((l) => l.statut === 'EN_ATTENTE').length;
        this.stats[2].amount = this.pendingDeliveries;
        this.updateDonutChartData(livraisons);
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des livraisons:', err);
        this.errorMessage = 'Failed to load deliveries. Please try again.';
      },
      complete: checkLoading,
    });

    this.apiService.getProduits().subscribe({
      next: (produits: Produit[]) => {
        this.totalProduits = produits.length;
        this.outOfStockProducts = produits.filter((p) => p.quantite <= 0).length;
        this.stats[3].amount = this.outOfStockProducts;
        this.stats[4].amount = this.totalProduits;
        this.recentProduits.data = produits.slice(0, 5);
        this.loadProductImages();
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des produits:', err);
        this.errorMessage = 'Failed to load products. Please try again.';
      },
      complete: checkLoading,
    });

    this.apiService.getUtilisateurs().subscribe({
      next: (utilisateurs: Utilisateur[]) => {
        this.totalUtilisateurs = utilisateurs.length;
        this.stats[5].amount = this.totalUtilisateurs;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des utilisateurs:', err);
        this.errorMessage = 'Failed to load users. Please try again.';
      },
      complete: checkLoading,
    });

    this.apiService.getCategories().subscribe({
      next: (categories: Categorie[]) => {
        this.apiService.getProduits().subscribe({
          next: (produits: Produit[]) => {
            const totalProducts = produits.length || 1;
            this.categoryStats.data = categories.map((category) => ({
              name: category.nom,
              count: produits.filter((p) => p.categorie?.id === category.id).length,
              percentage: Number(((produits.filter((p) => p.categorie?.id === category.id).length / totalProducts) * 100).toFixed(1)),
              id: category.id,
            }));
            this.pieChartData = {
              labels: this.categoryStats.data.map((c) => c.name),
              datasets: [
                {
                  data: this.categoryStats.data.map((c) => c.count),
                  backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
                  borderColor: '#ffffff',
                  borderWidth: 2,
                },
              ],
            };
          },
          error: (err) => {
            console.error('Erreur lors de la récupération des produits pour catégories:', err);
            this.errorMessage = 'Failed to load category data. Please try again.';
          },
          complete: checkLoading,
        });
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des catégories:', err);
        this.errorMessage = 'Failed to load categories. Please try again.';
      },
      complete: checkLoading,
    });
  }

  private loadProductImages() {
    this.recentProduits.data.forEach((produit) => {
      if (produit.id) {
        this.apiService.getProduitImage(produit.id).subscribe({
          next: (blob) => {
            const reader = new FileReader();
            reader.onloadend = () => {
              produit.image = reader.result as string;
            };
            reader.readAsDataURL(blob);
          },
          error: (err) => {
            console.error(`Erreur lors du chargement de l'image pour le produit ${produit.id}:`, err);
            produit.image = 'assets/images/default-product.png';
          },
        });
      }
    });
  }

  private updateLineChartData(commandes: CommandeDTO[]) {
    const now = new Date();
    let labels: string[] = [];
    let data: number[] = [];

    if (this.selectedPeriod === 'week') {
      labels = Array.from({ length: 7 }, (_, i) => {
        const date = new Date(now);
        date.setDate(now.getDate() - (6 - i));
        return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' });
      });
      data = labels.map((label) => {
        return commandes.filter((cmd) => {
          const cmdDate = new Date(cmd.dateCommande as string);
          return cmdDate.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }) === label;
        }).length;
      });
    } else if (this.selectedPeriod === 'month') {
      labels = Array.from({ length: 30 }, (_, i) => {
        const date = new Date(now);
        date.setDate(now.getDate() - (29 - i));
        return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' });
      });
      data = labels.map((label) => {
        return commandes.filter((cmd) => {
          const cmdDate = new Date(cmd.dateCommande as string);
          return cmdDate.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }) === label;
        }).length;
      });
    } else {
      labels = ['Q1', 'Q2', 'Q3', 'Q4'];
      data = labels.map((_, i) => {
        return commandes.filter((cmd) => {
          const cmdDate = new Date(cmd.dateCommande as string);
          return Math.floor(cmdDate.getMonth() / 3) === i;
        }).length;
      });
    }

    this.lineChartData = {
      labels,
      datasets: [
        {
          label: 'Orders Over Time',
          data,
          borderColor: '#2563eb',
          backgroundColor: 'rgba(37, 99, 235, 0.2)',
          fill: true,
          tension: 0.4,
        },
      ],
    };
  }

  private updateDonutChartData(livraisons: LivraisonDTO[]) {
    const counts = {
      EN_ATTENTE: livraisons.filter((l) => l.statut === 'EN_ATTENTE').length,
      EN_COURS: livraisons.filter((l) => l.statut === 'EN_COURS').length,
      LIVREE: livraisons.filter((l) => l.statut === 'LIVREE').length,
      ANNULEE: livraisons.filter((l) => l.statut === 'ANNULEE').length,
    };

    this.donutChartData = {
      labels: ['En Attente', 'En Cours', 'Livrée', 'Annulée'],
      datasets: [
        {
          data: [counts.EN_ATTENTE, counts.EN_COURS, counts.LIVREE, counts.ANNULEE],
          backgroundColor: ['#f59e0b', '#2563eb', '#14b8a6', '#ef4444'],
          borderColor: '#ffffff',
          borderWidth: 2,
        },
      ],
    };
  }

  openImageDialog(imageSrc: string, productName: string) {
    this.dialog.open(ImageDialogComponent, {
      data: { imageSrc, productName },
      panelClass: 'image-dialog',
    });
  }

  onPeriodChange() {
    this.loadData();
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

  onStatClick(stat: { route: string }): void {
    this.router.navigate([stat.route]);
  }

  viewCategory(stat: { id: number }): void {
    this.router.navigate(['/categories', stat.id]);
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadData();
  }
}

@Component({
  selector: 'app-image-dialog',
  template: `
    <div class="dialog-content">
      <h2 mat-dialog-title>{{ data.productName }}</h2>
      <mat-dialog-content>
        <img [src]="data.imageSrc" alt="Product Image" class="dialog-image">
      </mat-dialog-content>
      <mat-dialog-actions align="end">
        <button mat-button mat-dialog-close>Close</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [
    `
      .dialog-content {
        text-align: center;
        padding: 16px;
      }
      .dialog-image {
        max-width: 100%;
        max-height: 80vh;
        object-fit: contain;
        border-radius: 8px;
        border: 1px solid rgba(0, 0, 0, 0.1);
      }
      :host-context(.dark-theme) .dialog-image {
        border: 1px solid rgba(255, 255, 255, 0.1);
      }
    `,
  ],
  standalone: true,
  imports: [MatDialogModule, MatButtonModule],
})
export class ImageDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ImageDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { imageSrc: string; productName: string }
  ) {}
}