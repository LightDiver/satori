package main.lightdiver.skim;


import main.lightdiver.skim.entity.Language;
import main.lightdiver.skim.model.LocalizationBean;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;
import java.io.Serializable;
import java.util.Locale;

@FacesConverter("localeConverter")
public class LocaleConverter implements Converter, Serializable {
   @Override
    public Object getAsObject(FacesContext facesContext, UIComponent component, String submittedValue) {
        LocalizationBean localizationBean = (LocalizationBean) facesContext.getExternalContext().getSessionMap().get("localizationBean");
       /*for (int i = 0; i < Locale.getAvailableLocales().length; i++) {
           System.out.println(Locale.getAvailableLocales()[i]);
       }*/
 
        if (submittedValue.trim().equals("")) {
            return null;
        } else {
            for (Language p : localizationBean.getSelectedLanguage()) {
                if (p.getLangName().equals(submittedValue)) {
                    return p;
                }
            }
        }
        return null;

    }
    @Override
    public String getAsString(FacesContext arg0, UIComponent arg1, Object value) {
        if (value == null || value.equals("")) {
            return "";
        } else {
            return String.valueOf(((Language) value).getLangName());
        }

    }
}

