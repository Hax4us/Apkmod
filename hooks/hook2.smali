.class public Lcom/ysh/hook/App;
.super Landroid/app/Application;
.source "App.java"


# direct methods
.method public constructor <init>()V
    .registers 1

    .prologue
    .line 16
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    return-void
.end method


# virtual methods
.method public onCreate()V
    .registers 2

    .line 13
    new-instance v0, Lcom/ysh/hook/oooo0o00OO;

    invoke-direct {v0, p0}, Lcom/ysh/hook/oooo0o00OO;-><init>(Landroid/content/Context;)V

    invoke-static {v0}, Lcom/ysh/hook/ooo0ooOoo0;->OO0o0Oo00o(Ljava/lang/Object;)V

    .line 14
    invoke-static {p0}, Lcom/ysh/hook/ooo0ooOoo0;->OoooO00OOo(Ljava/lang/Object;)V

    .line 15
    invoke-super {p0}, Landroid/app/Application;->onCreate()V

    return-void
.end method