package main.lightdiver.skim.model;

import main.lightdiver.skim.entity.Category;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ManagedBean
@ViewScoped
public class ArticleBean {
    private List<Category> category;

    @PostConstruct
    public void init(){
        category = new ArrayList<>();
        category.add(new Category(1,"Інше"));
        category.add(new Category(2,"Швидке читання"));
        category.add(new Category(3,"Увага та пам'ять"));
        category.add(new Category(4,"Цікава математика"));
    }

    public List<Category> getCategory() {
        return category;
    }

    public void setCategory(List<Category> category) {
        this.category = category;
    }
}
