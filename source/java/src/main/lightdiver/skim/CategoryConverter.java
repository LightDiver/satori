package main.lightdiver.skim;

import main.lightdiver.skim.entity.Category;
import main.lightdiver.skim.model.ArticleBean;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;
import java.util.List;

@FacesConverter("categoryConverter")
public class CategoryConverter implements Converter {
        private List<Category> category;

        public Object getAsObject(FacesContext facesContext, UIComponent component, String s) {
            //ArticleBean articleBean = (ArticleBean) facesContext.getExternalContext().getSessionMap().get("articleBean");
            for (Category category : getCategory(facesContext)) {
                if (category.getCategoryName().equals(s)) {
                    return category;
                }
            }
            return null;
        }

        public String getAsString(FacesContext facesContext, UIComponent component, Object o) {
            if (o == null) return null;
            return ((Category) o).getCategoryName();
        }

        private List<Category> getCategory(FacesContext facesContext){
            if (category == null){
                ArticleBean articleBean = (ArticleBean)facesContext.getViewRoot().getViewMap().get("articleBean");
                category = articleBean.getCategory();
            }
            return category;
        }

}
