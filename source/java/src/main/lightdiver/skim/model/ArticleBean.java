package main.lightdiver.skim.model;

import main.lightdiver.skim.entity.Category;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

@ManagedBean
@ViewScoped
public class ArticleBean {
    private List<Category> category;

    @PostConstruct
    public void init(){
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        LocalizationBean localizationBean = (LocalizationBean) externalContext.getSessionMap().get("localizationBean");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        category = new ArrayList<>();
        category.add(new Category(1,msg.getString("cata.others")));
        category.add(new Category(2,msg.getString("cata.skimread")));
        category.add(new Category(3,msg.getString("cata.attentionmemory")));
        category.add(new Category(4,msg.getString("cata.interestingmathematics")));
    }

    public List<Category> getCategory() {
        return category;
    }

    public void setCategory(List<Category> category) {
        this.category = category;
    }
}
